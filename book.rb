class Book < ActiveRecord::Base
  validates :author, presence: true, on: :step_1
  validates :title, presence: true, on: :step_2
end