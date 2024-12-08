class AddImgToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :img, :string
  end
end
