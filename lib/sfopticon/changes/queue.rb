class SfOpticon::Changes::Queue
  attr_accessor :additions, :deletions, :modifications

  def initialize
    @log = SfOpticon::Logger
    @additions = []
    @deletions = []
    @modifications = []
  end

  def all_changes
    sorter([@additions, @deletions, @modifications].flatten)
  end

  def sorter(list)
    list.sort {|x,y|
      x.sf_object[:last_modified_date] <=> y.sf_object[:last_modified_date]
    }
  end

  ##
  # Apply each change in the queue to the dst_dir in order
  # and apply the block. This is for the SCM to commit, or
  # whatever.
  def apply_change_queue(src_dir, dst_dir)
    all_changes.each do |change|
      change.apply(src_dir, dst_dir)
      yield change
    end
  end
end
