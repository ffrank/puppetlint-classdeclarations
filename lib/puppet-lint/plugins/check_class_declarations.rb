# Public: Check the manifest for resource like class declarations that
# don't actually pass any parameters (in their most simple form)
PuppetLint.new_check(:unquoted_node_name) do
  def check
    class_tokens = tokens.select { |token| token.type == :CLASS }
    class_tokens.each do |klass|
      class_token_idx = tokens.index(klass)

      close_distance = tokens[class_token_idx..-1].index { |token| token.type == :RBRACE }

      condensed = tokens[class_token_idx, close_distance+1].reject { |token|
        token.type == :WHITESPACE || token.type == :NEWLINE
      }

      # class definition?
      if condensed[1].type != :LBRACE
        next
      end

      colon_idx = condensed.index { |token| token.type == :COLON }

      # colon followed by closing brace or semicolon?
      if [ :SEMICOLON, :RBRACE ].include?(condensed[colon_idx+1].type)
        notify :warning, {
          :message => 'needless use of resource like class declaration',
          :line    => klass.line,
          :column  => klass.column,
          :token   => klass,
        }
      end
    end
  end
end
