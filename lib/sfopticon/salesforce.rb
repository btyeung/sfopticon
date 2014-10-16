require 'extlib'

# This class performs all of the duties related to the SFDC through
# the Metaforce gem.
class SfOpticon::Salesforce
  attr_reader :env, :log, :config

  ##
  # @param env [SfOpticon::Environment]
  def initialize(env)
    @env = env
    @log = SfOpticon::Logger
    @config = SfOpticon::Settings.salesforce

    Metaforce.configure do |c|
      c.host = env.host
      c.log = false 
      c.api_version = '31.0'
      log.debug { "Host configured to #{c.host}"}
    end
  end

  # @!attribute client
  #    @return [Metaforce::Metadata::Client]
  def client
    @client ||= Metaforce::Metadata::Client.new :username => @env.username,
        :password => @env.password,
        :security_token => @env.securitytoken
  end

  def credentials_are_valid?
    login = Metaforce::Login.new @env.username, @env.password, @env.securitytoken
    login.login
  end

  # Gathers all metadata information for the list of metadata types, if provided.
  # If no metadata types are provided it will gather for the configured default list.
  def gather_metadata(type_list = [])
    @sfobjects = []
    mg = SfOpticon::SfObject

    types = if(type_list.empty?)
      metadata_types
    else
      type_list
    end

    types.each do |item|
      log.info { "Gathering #{item}" }
      begin
        records = client.list_metadata(item)

        # If there's only one item for this metadata type it is returned
        # as a bare hash, rather than an array of hashes.
        if records.is_a? Hash
          records = [records]
        end

        records.map! {|x| x.symbolize_keys }
        records.each do |rec|
          if rec.include?(:full_name) and rec.include?(:last_modified_date)
            # We need to avoid types with a suffix of "__hd"
            # an can be greedy about our regex because salesforce won't allow you
            # to name an object with a double-underscore. So this is always some
            # internal object that's unretrievable.
            if rec[:full_name] =~ /^.*?__hd/
              log.info { "Skipping item #{rec[:full_name]}" }
            else
              @sfobjects << mg.map_fields_from_sf(rec)
            end
          end
        end
      rescue => e
        if e.message == "undefined method `result' for nil:NilClass"
          log.info { "No custom #{item}'s to gather" }
        else
          log.error { "#{item} failed to gather: #{e.message}" }
        end
      end
      log.info { "#{item} complete." }
    end

    @sfobjects
  end

  # Retrieves all items in the manifest from the SFDC and extracts them
  # to the :extract_to parameter.
  def retrieve(opts = { :manifest => nil, :extract_to => '.' })
    opts[:manifest] ||= manifest(@env.sf_objects)
    log.debug { "Retrieving #{opts[:manifest].keys.join(',')} to #{opts[:extract_to]}" }
    client.retrieve_unpackaged(opts[:manifest]).extract_to(opts[:extract_to]).perform
  end

  # Lists the available metadata types. This is a list that
  # is currently maintained in the application.yml
  def metadata_types
    @names ||= self.class.metadata_types
  end

  # Lists the available metadata types. This is a list that
  # is currently maintained in the application.yml
  def self.metadata_types
    SfOpticon::Settings.salesforce.metadata_types
  end

  # Generates a Metaforce::Manifest based on the list of objects
  # given. The objects must have a :object_type key that corresponds
  # to a valid metadata type, and a :full_name key which corresponds
  # to the full_name in the SfOpticon::SfObject model.
  def manifest(object_list)
    mf = {}

    object_list.each do |sf_object|
      sym = sf_object[:object_type].snake_case.to_sym
      if not mf.has_key? sym
        mf[sym] = []
      end

      mf[sym].push(sf_object[:full_name])
    end

    Metaforce::Manifest.new(mf)
  end
end
