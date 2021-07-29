require "action_controller/railtie"
require "action_cable/engine"
require "active_model"
require "active_record"
require "nulldb/rails"
require "rails/command"
require "rails/commands/server/server_command"
require "cable_ready"
require "stimulus_reflex"
require_relative "./book"
require_relative "./restaurant"

module ApplicationCable; end

class ApplicationCable::Connection < ActionCable::Connection::Base
  identified_by :session_id

  def connect
    self.session_id = request.session.id
  end  
end

class ApplicationCable::Channel < ActionCable::Channel::Base; end

class ApplicationController < ActionController::Base; end

class ApplicationReflex < StimulusReflex::Reflex; end

class WizardReflex < ApplicationReflex
  def refresh
    session[:"new_#{resource_name.underscore}"] = resource_class.new(resource_params)
    
    step = element.dataset.step.to_i
    @current_step = if session[:"new_#{resource_name.underscore}"].valid?("step_#{step}".to_sym) && element.dataset.incr.present?
      step + element.dataset.incr.to_i
    else
      step
    end

    cable_ready.push_state(url: "?tab=#{@current_step}")
  end

  private

  RESOURCE_ALLOWLIST = {
    "books#new" => "Book",
    "restaurants#new" => "Restaurant"
  }.freeze

  RESOURCE_PARAMS_ALLOWLIST = {
    "books#new" => "book",
    "restaurants#new" => "restaurant"
  }.freeze

  def resource_name
    RESOURCE_ALLOWLIST["#{params["controller"]}##{params["action"]}"]
  end

  def resource_class
    resource_name.safe_constantize
  end

  def resource_params
    # call to private method
    param_name = RESOURCE_PARAMS_ALLOWLIST["#{params["controller"]}##{params["action"]}"]
    controller.send("#{param_name}_params")
  end
end

class BookWizardReflex < WizardReflex; end
class RestaurantWizardReflex < WizardReflex; end

require_relative "./books_controller"
require_relative "./restaurants_controller"

class MiniApp < Rails::Application
  require "stimulus_reflex/../../app/channels/stimulus_reflex/channel"

  config.action_controller.perform_caching = true
  config.consider_all_requests_local = true
  config.public_file_server.enabled = true
  config.secret_key_base = "cde22ece34fdd96d8c72ab3e5c17ac86"
  config.secret_token = "bf56dfbbe596131bfca591d1d9ed2021"
  config.session_store :cache_store
  config.hosts.clear

  Rails.cache = ActiveSupport::Cache::RedisCacheStore.new(url: "redis://localhost:6379/1")
  Rails.logger = ActionCable.server.config.logger = Logger.new($stdout)
  ActionCable.server.config.cable = {"adapter" => "redis", "url" => "redis://localhost:6379/1"}

  routes.draw do
    mount ActionCable.server => "/cable"
    get '___glitch_loading_status___', to: redirect('/')
    resources :books, only: :new
    resources :restaurants, only: :new
    root "books#new"
  end
end

ActiveRecord::Base.establish_connection adapter: :nulldb, schema: "schema.rb"

Rails::Server.new(app: MiniApp, Host: "0.0.0.0", Port: ARGV[0]).start
