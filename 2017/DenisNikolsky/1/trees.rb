require 'rubygems'
require 'json'

class Tree
  attr_accessor :left, :right, :data
  MAX_SUM_NODE = 5000
  MAX_DEPTH = 5

  def initialize(data = nil)
    @data = data
  end

  def insert(item)
    if @data.nil?
      @data = item[0]
      insert(item[1])
    end
    item.each do |node|
      if @left.nil?
        insert_left(node)
      elsif @right.nil?
        insert_right(node)
      end
    end
  end

  def insert_left(node)
    if node.is_a?(Array)
      @left = Tree.new(node[0])
      @left.insert(node[1])
    else
      @left = Tree.new(node)
    end
  end

  def insert_right(node)
    if node.is_a?(Array)
      @right = Tree.new(node[0])
      @right.insert(node[1])
    else
      @right = Tree.new(node)
    end
  end

  def max_depth
    depth = 1
    node = @left
    loop do
      break if node.left.nil?
      depth += 1
      node = node.left
    end
    depth
  end

  def print_tree
    depth = max_depth
    spaces = 40 * depth
    print_format(spaces, @data.to_s)
    puts
    print_format(spaces, '/  \\')
    puts
    list = [@left, @right]
    print_node(list, depth)
  end

  def print_node(list, depth)
    level = 1
    printed_elem = 0
    loop do
      break if list.empty?
      elements = 2**level
      node_left = list.shift
      node_right = list.shift
      spaces = 40 * depth / elements
      print_format(spaces, node_left.data.to_s)
      print_format(spaces * 2, node_right.data.to_s)
      printed_elem += 2
      add_in_list(list, node_left)
      add_in_list(list, node_right)
      if printed_elem == elements
        puts
        return if level == depth
        print_branch(elements, spaces)
        level += 1
        printed_elem = 0
      else
        print ' ' * spaces
      end
    end
  end

  def print_branch(elements, spaces)
    elements.times do
      print_format(spaces - 1, '/  \\')
      print ' ' * (spaces + 1)
    end
    puts
  end

  def print_format(spaces, data)
    print format("%#{spaces}s", data)
  end

  def add_in_list(list, node)
    list << node.left unless node.left.nil?
    list << node.right unless node.right.nil?
    list
  end

  def make_decision(arr)
    return 'срубить' if arr.flatten.sum > MAX_SUM_NODE
    return 'обрезать' if max_depth > MAX_DEPTH
    'оставить'
  end
end

tree_name = ENV['NAME']
all_trees = Dir['trees/*.tree']
all_trees.sort!
if tree_name.nil?
  all_trees.each do |name|
    puts name
    arr = JSON.parse(File.open(name.to_s, &:read))
    tree = Tree.new
    tree.insert(arr)
    tree.print_tree
    puts tree.make_decision(arr)
    puts 'Желаете продолжить? [y/n]'
    answer = gets.chomp.downcase
    if answer == 'n'
      puts 'Спасибо, что были в нашем лесу'
      break
    end
  end
elsif all_trees.include?('trees/'.concat(tree_name).concat('.tree'))
  string = File.open("trees/#{tree_name}.tree", &:read)
  arr = JSON.parse(string)
  tree = Tree.new
  tree.insert(arr)
  tree.print_tree
else
  puts 'Данное дерево не растет в данном лесу.'
end
