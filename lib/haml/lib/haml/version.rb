require 'haml/util'

module Haml
  # Handles Haml version-reporting.
  # Haml not only reports the standard three version numbers,
  # but its Git revision hash as well,
  # if it was installed from Git.
  module Version
    include Haml::Util

    # Returns a hash representing the version of Haml.
    # The `:major`, `:minor`, and `:teeny` keys have their respective numbers as Fixnums.
    # The `:name` key has the name of the version.
    # The `:string` key contains a human-readable string representation of the version.
    # The `:number` key is the major, minor, and teeny keys separated by periods.
    # If Haml is checked out from Git, the `:rev` key will have the revision hash.
    # For example:
    #
    #     {
    #       :string => "2.1.0.9616393",
    #       :rev    => "9616393b8924ef36639c7e82aa88a51a24d16949",
    #       :number => "2.1.0",
    #       :major  => 2, :minor => 1, :teeny => 0
    #     }
    #
    # @return [Hash<Symbol, String/Fixnum>] The version hash
    def version
      return @@version if defined?(@@version)

      numbers = File.read(scope('VERSION')).strip.split('.').map { |n| n.to_i }
      name = File.read(scope('VERSION_NAME')).strip
      @@version = {
        :major => numbers[0],
        :minor => numbers[1],
        :teeny => numbers[2],
        :name => name
      }
      @@version[:number] = [:major, :minor, :teeny].map { |comp| @@version[comp] }.compact.join('.')
      @@version[:string] = @@version[:number].dup

      if File.exists?(scope('REVISION'))
        rev = File.read(scope('REVISION')).strip
        rev = nil if rev !~ /^([a-f0-9]+|\(.*\))$/
      end

      if (rev.nil? || rev == '(unknown)') && File.exists?(scope('.git/HEAD'))
        rev = File.read(scope('.git/HEAD')).strip
        if rev =~ /^ref: (.*)$/
          rev = File.read(scope(".git/#{$1}")).strip
        end
      end

      if rev
        @@version[:rev] = rev
        unless rev[0] == ?(
          @@version[:string] << "." << rev[0...7]
        end
        @@version[:string] << " (#{name})"
      end

      @@version
    end
  end
end
