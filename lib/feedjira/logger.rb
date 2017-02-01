# Feedjira.logger
module Feedjira
  class << self
    attr_writer :logger

    # Provides a global logger instance for Feedjira
    # If no logger is set by the user, a logger using DEFAULTS is provided
    # @see Feedjira::Config::DEFAULTS
    # @see Feedjira::Logger
    #
    # @return [Logger]
    def logger
      @logger ||= build_logger
    end

    private

    def build_logger
      ::Logger.new(Feedjira.logger_io).tap do |logger|
        logger.level = Feedjira.logger_level
      end
    end
  end

  # Provide some convenience methods for logging
  # So the Progname mustn't be passed on every call
  # @example
  #   Feedjira::Logger.info { "My Info Message" }
  module Logger
    class << self
      # Log a message given as a block if level DEBUG is set
      #
      # @yieldreturn [String] The Message to log
      def debug
        Feedjira.logger.debug('Feedjira') { yield }
      end

      # Log a message given as a block if level INFO is set
      #
      # @yieldreturn [String] The Message to log
      def info
        Feedjira.logger.info('Feedjira') { yield }
      end

      # Log a message given as a block if level WARN is set
      #
      # @yieldreturn [String] The Message to log
      def warn
        Feedjira.logger.warn('Feedjira') { yield }
      end

      # Log a message given as a block if level ERROR is set
      #
      # @yieldreturn [String] The Message to log
      def error
        Feedjira.logger.error('Feedjira') { yield }
      end

      # Log a message given as a block if level FATAL is set
      #
      # @yieldreturn [String] The Message to log
      def fatal
        Feedjira.logger.fatal('Feedjira') { yield }
      end

      # Log exceptions with message and backtrace in a common way
      # Exceptions will only be logged when severity level 'DEBUG' is set
      #
      # @example Log an Exception with a custom message
      #   Feedjira::Logger.exception(StandardError.new) {
      #     'Log this great message'
      #   }
      #
      # @param e [Exception] The exception to log
      # @yieldreturn [String] The Message to log (optional)
      def exception(e)
        Feedjira.logger.debug('Feedjira') do
          msg = block_given? ? "#{yield}\n" : ''
          msg + "Message: #{e.message}\n#{e.backtrace.join("\n ")}"
        end
      end
    end
  end
end
