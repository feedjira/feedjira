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
      :logger,
      :parsers,
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

    # Reset Feedjira's configuration to defaults
    #
    # @example
    #   Feedjira.reset_configuration!
    def reset_configuration!
      set_default_configuration
    end

    # @private
    def self.extended(base)
      base.set_default_configuration
    end

    # @private
    def set_default_configuration
      self.follow_redirect_limit = 3
      self.logger = default_logger
      self.parsers = default_parsers
      self.request_timeout = 30
      self.strip_whitespace = false
      self.user_agent = "Feedjira #{Feedjira::VERSION}"
    end

    private

    # @private
    def default_logger
      Logger.new(STDOUT).tap do |logger|
        logger.progname = 'Feedjira'
        logger.level = Logger::WARN
      end
    end

    # @private
    def default_parsers
      [
        Feedjira::Parser::RSSFeedBurner,
        Feedjira::Parser::GoogleDocsAtom,
        Feedjira::Parser::AtomYoutube,
        Feedjira::Parser::AtomFeedBurner,
        Feedjira::Parser::Atom,
        Feedjira::Parser::ITunesRSS,
        Feedjira::Parser::RSS
      ]
    end
  end
end
