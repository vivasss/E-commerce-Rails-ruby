class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :nullify
  has_many :products, dependent: :nullify
  
  has_one_attached :image
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :root_categories, -> { where(parent_id: nil) }
  scope :ordered, -> { order(position: :asc, name: :asc) }
  
  def self.tree
    root_categories.active.ordered.includes(:children)
  end
  
  def ancestors
    ancestors_list = []
    current = parent
    while current
      ancestors_list.unshift(current)
      current = current.parent
    end
    ancestors_list
  end
  
  def descendants
    children.flat_map { |child| [child] + child.descendants }
  end
  
  def all_product_ids
    product_ids + descendants.flat_map(&:product_ids)
  end
  
  def products_count
    products.active.count + descendants.sum { |d| d.products.active.count }
  end
  
  def depth
    ancestors.count
  end
end
