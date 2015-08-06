def to_be_or_not_to_be(to_be)
  the_question = to_be || !to_be
  that = the_question
end

def a_tale_of_two_cities(period, times, age, epoch, season, spring)
  period.was << times[:best] << times[:worst]
  period.was << age[:wisdom] << age[:foolishness]
  period.was << epoch[:belief] << epoch[:incredulity]
  period.was << season[:light] << season[:darkness]
  period.was << spring[:hope] << winter[:despair]
end

def old_man_and_the_sea
  class OldMan
    attr_accessor :fishes, :boat, :location, :days_without_taking_a_fish

    def initialize(fishes, boat, location)
      @fishes = fishes
      @boat = boat
      @location = location
    end

    def days_without_taking_a_fish=(days)
      self.days_without_taking_a_fish = days
    end
  end
  he = OldMan.new({fishes: "alone", boat: "skiff", location: "Gulf Stream"})
  he.days_without_taking_a_fish = 84
end

def one_hundred_years_of_solitude(years, colonel_aureliano_buendia)
  case years
  when "later"
    while colonel_aureliano_buendia.faced(FiringSquad.new)
      colonel_aureliano_buendia.remembered(:that_distant_afternoon)
    end
  end
end

class ColonelAureliano < Buendia
  def remembered(memory)
    self.send(memory)
  end

  def that_distant_afternoon
    self.father.discover_ice(self)
  end
end

def leo_tolstoy
  happy_families = Family.all.collect{|f| f.happy == true}
  unhappy_families = Family.all.collect{|f| f.happy == false}
  happy_families.all?.with_index(0) {|hf, i| hf[i-1] == hf[i] if i == 1 } == true
  unhappy_families.none?.with_index(0) {|uhf, i| uhf[i-1] == uhf[i] if i == 1 } == true
end

def the_adventures_of_tom_sawyer(you, tom_sawyer)
  you.know_about(tom_sawyer) = false if !you.read(Book.find_by(name: "The Adventures of Tom Sawyer"))
  if you.know_about(tom_sawyer) || !you.know_about(tom_sawyer)
    it_matters = false
  end
end