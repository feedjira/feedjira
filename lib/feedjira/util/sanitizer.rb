# frozen_string_literal: true

module Feedjira
  module Util
    # Utility methods for sanitizing content
    module Sanitizer
      # Sanitize a string by removing dangerous HTML content
      # @param content [String] the content to sanitize
      # @return [String] the sanitized content
      def self.sanitize(content)
        return content unless content.is_a?(String)

        Loofah.scrub_fragment(content, :prune).to_s
      end

      # Sanitize a string in place by removing dangerous HTML content
      # @param content [String] the content to sanitize in place
      # @return [String] the sanitized content
      def self.sanitize!(content)
        return content unless content.is_a?(String)

        sanitized = sanitize(content)
        content.replace(sanitized)
      end
    end
  end
end
