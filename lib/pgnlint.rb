require 'parslet'
require 'pgn'
require 'pp'
require_relative 'pgnlint/parser'
require_relative 'pgnlint/transformator'

# Testing my parser with pgn: https://github.com/capicue/pgn

begin
  game = PGNLint::Parser.new.parse(File.open(File.join(File.dirname(__FILE__), '..', '/examples/Tobias-Georg2.pgn')).read,
                                   reporter: Parslet::ErrorReporter::Deepest.new)
  rescue Parslet::ParseFailed => failure
    puts failure.cause.ascii_tree
end

pp game

transformed = PGNLint::Transform.new.apply(game)[:database].first[:game]

pp transformed

pgn_game = PGN::Game.new(transformed[:moves], transformed[:tags], transformed[:termination])
