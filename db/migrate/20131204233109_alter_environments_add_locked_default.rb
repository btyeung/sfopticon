class AlterEnvironmentsAddLockedDefault < ActiveRecord::Migration
  def change
    change_column :environments, :locked, :boolean, :default => false
  end
end
