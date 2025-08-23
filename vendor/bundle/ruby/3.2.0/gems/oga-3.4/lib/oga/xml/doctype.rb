module Oga
  module XML
    # Class used for storing information about Doctypes.
    class Doctype < Node
      # The name of the doctype (e.g. "HTML").
      # @return [String]
      attr_accessor :name

      # The type of the doctype (e.g. "PUBLIC").
      # @return [String]
      attr_accessor :type

      # The public ID of the doctype.
      # @return [String]
      attr_accessor :public_id

      # The system ID of the doctype.
      # @return [String]
      attr_accessor :system_id

      # The inline doctype rules.
      # @return [String]
      attr_accessor :inline_rules

      # @example
      #  dtd = Doctype.new(:name => 'html', :type => 'PUBLIC')
      #
      # @param [Hash] options
      #
      # @option options [String] :name
      # @option options [String] :type
      # @option options [String] :public_id
      # @option options [String] :system_id
      def initialize(options = {})
        @name         = options[:name]
        @type         = options[:type]
        @public_id    = options[:public_id]
        @system_id    = options[:system_id]
        @inline_rules = options[:inline_rules]
      end

      # Inspects the doctype.
      #
      # @return [String]
      def inspect
        segments = []

        [:name, :type, :public_id, :system_id, :inline_rules].each do |attr|
          value = send(attr)

          if value and !value.empty?
            segments << "#{attr}: #{value.inspect}"
          end
        end

        "Doctype(#{segments.join(' ')})"
      end
    end # Doctype
  end # XML
end # Oga
