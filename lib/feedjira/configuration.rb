# Feedjira::Configuration
module Feedjira
  # Provides global configuration options for Feedjira
  #
  # @example Set configuration options using a block
  #   Feedjira.configure do |config|
  #     config.strip_whitespace = true
  #   end
  module Configuration
    attr_accessor(
      :follow_redirect_limit,
      :request_timeout,
      :strip_whitespace,
      :user_agent
    )

    # Modify Feedjira's current configuration
    #
    # @yieldparam [Feedjria] config current Feedjira config
    # @example
    #   Feedjira.configure do |config|
    #     config.strip_whitespace = true
    #   end
    def configure
      yield self
    end

    # @private
    def self.extended(base)
      base.set_default_configuration
    end

    # @private
    def set_default_configuration
      self.follow_redirect_limit = 3
      self.request_timeout = 30
      self.strip_whitespace = false
      self.user_agent = "Feedjira #{Feedjira::VERSION}"
    end
  end
end
