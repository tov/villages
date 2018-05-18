def family_wants_another_child?(family)
  probability_space = if family.empty?
    [true, true, true, false]
  else
    [true, false, false, false]
  end

  probability_space.sample
end

def family_allowed_another_child?(family)
  family.last != :boy
end

def generate_child
  [:boy, :girl].sample
end

def simulate_village(number_of_families)
  village = []

  number_of_families.times do
    family = []

    while(family_allowed_another_child?(family) && family_wants_another_child?(family))
      family << generate_child
    end

    village << family
  end

  village
end

############################################################

def village_children(village)
  village.flatten
end

def village_gender_count(village, gender)
  village_children(village).count{|child| child == gender}.to_f
end

def ratio_of_boys_to_girls(village)
  number_of_boys = village_gender_count(village, :boy)
  number_of_girls = village_gender_count(village, :girl)

  number_of_boys / number_of_girls
end

def avg_kids_per_family(village)
  village_children(village).count.to_f / village.count.to_f
end

def avg_boys_per_family(village)
  village_gender_count(village, :boy) / village.count.to_f
end

def avg_girls_per_family(village)
  village_gender_count(village, :girl) / village.count.to_f
end

############################################################

village = simulate_village(1000000)

# puts ratio_of_boys_to_girls(village)
puts avg_kids_per_family(village)
# puts avg_boys_per_family(village)
# puts avg_girls_per_family(village)
