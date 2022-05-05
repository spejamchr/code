#!/usr/bin/env ruby

# frozen_string_literal: true

require 'open-uri'
require 'json'

class DirectedGraphExplorer
  API = "https://nodes-on-nodes-challenge.herokuapp.com/nodes/"

  START = "089ef556-dfff-4ff2-9733-654645be56fe"

  attr_accessor :ids, :nodes

  def initialize
    @ids = [START]
    @nodes = []
  end

  def report
    explore
    puts "Total unique nodes: #{ids.count}"
    puts "The node with the most parents is: #{popular.first} with #{popular.last} parents"
    puts "nodes: #{nodes}"
  end

  private

  def find_nodes
    self.nodes = ::JSON.parse(::URI.parse("#{API}#{ids.join(',')}").read)
    self.ids = (ids + nodes.flat_map { |node| node.fetch('child_node_ids') }).uniq.sort
  end

  def popular
    nodes
      .flat_map { |node| node.fetch('child_node_ids') }
      .group_by(&:itself)
      .transform_values(&:count)
      .to_a
      .max_by(&:last)
  end

  def explore
    old_ids = 0
    # This is rather inefficient, but it's so easy. If it works and it's fast,
    # than it would be a premature optimization to do it more efficiently. ;)
    #
    # If this needed to be faster, I'd keep track of "explored" vs "to-explore"
    # nodes separately.
    until old_ids == ids.count
      old_ids = ids.count
      find_nodes
    end
  end
end

::DirectedGraphExplorer.new.report
# Total unique nodes: 30
# The node with the most parents is: a06c90bf-e635-4812-992e-f7b1e2408a3f with 3 parents
