module Oga
  # @api private
  class Blacklist
    # @return [Set]
    attr_reader :names

    # @param [Array] names
    def initialize(names)
      @names = Set.new(names + names.map(&:upcase))
    end

    # @yieldparam [String]
    def each
      names.each do |value|
        yield value
      end
    end

    # @return [TrueClass|FalseClass]
    def allow?(name)
      !names.include?(name)
    end

    # @param [Oga::Blacklist] other
    # @return [Oga::Blacklist]
    def +(other)
      self.class.new(names + other.names)
    end
  end # Blacklist
end # Oga
