require 'parslet'

module PGNLint
  class Parser < Parslet::Parser
    rule(:space) { match("[[:space:]]").repeat(1) }
    rule(:space?) { space.maybe }
  
    root(:pgn_database)
  
    rule(:pgn_database) do
      pgn_game.as(:game).repeat.as(:database)
    end
  
    rule(:pgn_game) do
      tag_section.as(:tags) >>
      movetext_section >>
      space?
    end
  
    rule(:tag_section) { tag_pair.repeat }
  
    rule(:tag_pair) do
      str("[") >>
      tag_name.as(:tag_name) >>
      space >> tag_value >>
      str("]") >>
      space?
    end
  
    rule(:tag_name) { match('[A-Za-z_]').repeat(1) }
  
    rule(:tag_value) do
      str('"') >>
      match('[[:print:]&&[^"]]').repeat(1).as(:tag_value) >>
      str('"')
    end
  
    rule(:movetext_section) do
      element_sequence.as(:moves) >>
      game_termination.as(:termination)
    end
  
    rule(:element_sequence) do
      (element | variation.as(:variation) | comment >> space?).repeat
    end
  
    rule(:element) do
      (move_number.as(:move_number) >> space?).maybe >>
      san_move.as(:san_move) >> space? >>
      (nag.as(:nag) >> space).maybe
    end
  
    rule(:string) { match('[[:print:]&&[^}]]').repeat(1) }
  
    rule(:game_termination) { str('1-0') | str('0-1') | str('1/2-1/2') | str('*') }
  
    rule(:move_number) { match('[0-9]').repeat(1) >> str('.').repeat(1) }
  
    rule(:san_move) { (castle | pawn_move.as(:pawn) | major_move.as(:major) ) >> promotion.as(:promotion).maybe >> check.as(:check).maybe }
  
    rule(:nag) { str('$') >> match('[0-9]').repeat(1) }
  
    rule(:comment) { str("{") >> space? >> string.as(:comment) >> space? >> str("}") }
    # TODO multiline comments
  
    rule(:variation) { str("(") >> element_sequence >> str(")") >> space? }
  
    rule(:check) { match('[+#]') }
    rule(:promotion) { str('=') >> (str('B').as(:bishop) | str('N').as(:knight) | str('Q').as(:queen) | str('R').as(:rook)) }
  
    rule(:major_move) do
      match('[BKNQR]') >>
      # TODO better optional from rank and file
      str('x').maybe >>
      match('[a-h]') >>
      match('[1-8]') |
  
      match('[BKNQR]') >>
      match('[a-h]') >>
      str('x').maybe >>
      match('[a-h]') >>
      match('[1-8]')
    end
  
    rule(:pawn_move) do
      match('[a-h]') >>
      (match('[1-8]') | str('x')) >>
      (match('[a-h]') >> match('[1-8]')).maybe
    end
  
    rule(:castle) do
      (str('O-O') | str('0-0')).as(:castle) >> space |
      (str('O-O-O') | str('0-0-0')).as(:castle)
    end
  end
end
