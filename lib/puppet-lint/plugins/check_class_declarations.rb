# Public: Check the manifest for resource like class declarations that
# don't actually pass any parameters
PuppetLint.new_check(:unquoted_node_name) do
  def check
    class_tokens = tokens.select { |token| token.type == :CLASS }
    class_tokens.each do |klass|
      class_token_idx = tokens.index(klass)

      # class definition?
      if tokens[class_token_idx+1] != :LBRACE
        next
      end

      colon_token = tokens[class_token_idx+1..-1].find { |token| token.type == :COLON }
      colon_idx = tokens.index(colon_token)

      # colon followed by closing brace or semicolon?
      if [ :SEMICOLON, :RBRACE ].contains? tokens[colon_idx+1]
        notify :warning, {
          :message => 'needless use of resource like class declaration',
          :line    => klass.line,
          :column  => klass.column,
          :token   => klass,
        }
      end
    end
  end

  def fix(problem)
    index = tokens.index(problem)
    types = tokens[index..index+4].collect { |token| token.type }
    if types[0] == :CLASS &&
       types[1] == :LBRACE &&
       types[3] == :COLON &&
       types[4] == :RBRACE &&
       [ :NAME, :STRING, :SSTRING ].contains? types[2]
      tokens.delete_at(index+4)
      tokens.delete_at(index+3)
      tokens.delete_at(index+1)
      problem[:token].type = :NAME
      problem[:token].value = 'include'
    else
      raise PuppetLint::NoFix
    end
  end
end
