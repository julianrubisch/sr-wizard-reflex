class Book < ActiveRecord::Base
  def self.all
    [Book.new(title: "Recursion", author: "Blake Crouch"), Book.new(title: "VALIS", author: "Philip K. Dick")]    
  end
end