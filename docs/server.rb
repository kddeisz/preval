# frozen_string_literal: true

require 'bundler/setup'
require 'preval'
require 'sinatra'

Preval::Visitors::Arithmetic.enable!
Preval::Visitors::Loops.enable!
Preval::Visitors::Micro.enable!

get '/' do
  send_file(File.expand_path('index.html', __dir__))
end

post '/' do
  Preval.process(request.body.read).tap do |response|
    halt 422 unless response
  end
end
