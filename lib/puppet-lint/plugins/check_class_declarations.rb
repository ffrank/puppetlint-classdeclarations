# Public: Check the manifest for resource like class declarations that
# don't actually pass any parameters
PuppetLint.new_check(:unquoted_node_name) do
  def check
    class_tokens = tokens.select { |token| token.type == :CLASS }
    class_tokens.each do |klass|
      class_token_idx = tokens.index(klass)

      close_token = tokens[class_token_idx..-1].find { |token| token.type == :RBRACE }
      close_token_idx = tokens.index(close_token)

      condensed = tokens[class_token_idx..close_token_idx].reject { |token|
        token.type == :WHITESPACE || token.type == :NEWLINE
      }

      # class definition?
      if condensed[1].type != :LBRACE
        next
      end

      colon_token = condensed.find { |token| token.type == :COLON }
      colon_idx = condensed.index(colon_token)

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
