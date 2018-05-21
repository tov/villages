# Write a program that will generate a simulation of a village that scientists are studying.
# In the village, there is a rule that once you have a boy, you can not have any further children.
#
# So acceptable families are:
#   Girl, Girl
#   Girl
#   Boy
#   Girl, Boy
#   Girl, Girl, Boy
#
# However examples of unacceptable families are:
#   Boy, Girl
#   Boy, Boy
#   Girl, Boy, Girl
#
#
# They also noticed that only 75% of families will want any children at all.
# After the first child, families have a 25% chance of having each subsequent child.
#
#
#   Implement a method that will return a data structure that shows each families children in the village.
#
#   Using this method, calculate the follow.
#
#     1. Ratio of boys to girls
#     2. Avg kids per family
#     3. Avg boys per family
#     4. Avg girls per family

class Child
  def self.random
    [Boy, Girl].sample.new
  end
end

class Boy < Child
  def boy?
    true
  end

  def girl?
    false
  end
end

class Girl < Child
  def boy?
    false
  end

  def girl?
    true
  end
end

class Stats
  def initialize(families)
    @families = families
  end

  def generate
    {
      ratio_boys_to_girls:  generate_ratios,
      avg_kids_per_family:  generate_average_kids,
      avg_boys_per_family:  generate_average_boys,
      avg_girls_per_family: generate_average_girls
    }
  end

  private

  def generate_ratios
    @boy_count  = 0
    @girl_count = 0
    @families.each do |family|
      @boy_count  += family.count_of_boys
      @girl_count += family.count_of_girls
    end

    if @girl_count.zero?
      1.0
    else
      @boy_count / @girl_count.to_f
    end
  end

  def generate_average_kids
    (@boy_count + @girl_count) / @families.size.to_f
  end

  def generate_average_boys
    @boy_count / @families.size.to_f
  end

  def generate_average_girls
    @girl_count / @families.size.to_f
  end
end

class Family
  PROBABILITY_WANT_CHILD       = 0.75
  PROBABILITY_SUBSEQUENT_CHILD = 0.25

  def self.stats(families)
    Stats.new(families)
  end

  def initialize
    @children = []
  end

  def wants_child?
    rand < PROBABILITY_WANT_CHILD
  end

  def fertile?
    rand < PROBABILITY_SUBSEQUENT_CHILD
  end

  def birth_all_children
    begin
      # loops at least once so we are guaranteed to
      # always have at least one child at this point
      birth_child
    end while !birthed_boy? && fertile?
  end

  def birth_child
    @children << Child.random
  end

  def birthed_boy?
    @children.any? { |child| child.boy? }
  end

  def count_of_boys
    @children.select(&:boy?).size
  end

  def count_of_girls
    @children.select(&:girl?).size
  end
end

def simulate_families(number_of_families)
  families = []
  number_of_families.times do
    family = Family.new
    families << family
    next unless family.wants_child?

    family.birth_all_children
  end

  families
end

families = simulate_families(1_000_000)

require 'pp'
pp Family.stats(families).generate
