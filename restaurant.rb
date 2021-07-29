class Restaurant < ActiveRecord::Base
  validates :name, presence: true, on: :step_1
end