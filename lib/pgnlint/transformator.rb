require 'parslet'

module PGNLint
  class Transform < Parslet::Transform
    rule(:tag_name => simple(:t), :tag_value => simple(:n)) {{t.to_s => n.to_s} }
    rule(:kingside => simple(:c)) { c.to_s }
    rule(:queenside => simple(:c)) { c.to_s }
  #  rule(:castle => simple(:c)) { c.to_s }
    #rule(:variation => sequence(:x)) { }
    rule(:tags => subtree(:ts), :moves => subtree(:ms), :termination => simple(:t)) do
      { :tags => ts.inject(:merge),
        :moves => ms.map do |x|
          if x.key? :variation then next; end
          if x and x.key? :san_move
            x[:san_move].map do |_,v|
                v
            end.join
          end
        end.compact,
        :termination => t.to_s }
    end
    rule(:move_number => simple(:x)) { }
  end
end
