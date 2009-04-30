require File.dirname(__FILE__) + '/test_helper'

class DeepCloningTest < Test::Unit::TestCase
  fixtures :pirates, :pirates_unions, :gold_pieces, :treasures, :mateys, :parrots

  def setup
    @jack = Pirate.find(pirates(:jack).id)
    @polly= Parrot.find(parrots(:polly).id)
  end

  def test_single_clone_exception
    clone = @jack.clone(:except => :name)
    assert clone.save
    assert_equal pirates(:jack).name, @jack.clone.name # Old behavour
    assert_nil clone.name
    assert_equal pirates(:jack).nick_name, clone.nick_name
  end
  
  def test_multiple_clone_exception
    clone = @jack.clone(:except => [:name, :nick_name])
    assert clone.save
    assert_nil clone.name
    assert_equal 'no nickname', clone.nick_name
    assert_equal pirates(:jack).age, clone.age
  end
  
  def test_single_include_association
    clone = @jack.clone(:include => :mateys)
    assert clone.save
    assert_equal 1, clone.mateys.size
  end
  
  def test_multiple_include_association
    clone = @jack.clone(:include => [:mateys, :treasures])
    assert clone.save
    assert_equal 1, clone.mateys.size
    assert_equal 1, clone.treasures.size
  end
  
  def test_deep_include_association
    clone = @jack.clone(:include => {:treasures => :gold_pieces})
    assert clone.save
    assert_equal 1, clone.treasures.size
    assert_equal 1, clone.gold_pieces.size
  end
  
  def test_multiple_and_deep_include_association
    clone = @jack.clone(:include => {:treasures => :gold_pieces, :mateys => {}})
    assert clone.save
    assert_equal 1, clone.treasures.size
    assert_equal 1, clone.gold_pieces.size
    assert_equal 1, clone.mateys.size
  end
  
  def test_multiple_and_deep_include_association_with_array
    clone = @jack.clone(:include => [{:treasures => :gold_pieces}, :mateys])
    assert clone.save
    assert_equal 1, clone.treasures.size
    assert_equal 1, clone.gold_pieces.size
    assert_equal 1, clone.mateys.size
  end
  
  def test_with_belongs_to_relation
    clone = @jack.clone(:include => :parrot)
    assert clone.save
    assert_not_equal clone.parrot, @jack.parrot
  end

  def test_deep_with_only_association_cloned_instead_of_actual_object
    pirate_union = PiratesUnion.find(:first)
    @jack.pirates_unions << pirate_union
    original_pirates_unions_count = PiratesUnion.count
    clone = @jack.clone(:include_association => :pirates_unions)
    assert clone.save
    assert_equal clone.pirates_unions, @jack.pirates_unions
    assert_equal original_pirates_unions_count, PiratesUnion.count
  end
end