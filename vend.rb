#!/usr/bin/ruby
#encoding: shift_jis

require 'set'
require "./drink"
#drink��@drinks[name]�̎���Drink.new��2�p�^�[������̂ŕ���킵��
#�ܖ������̓o�^���@
	#���������ܖ������ł̂߂�ǂ�����
class Vending_machine
  attr_reader :amount, :sale_amount, :drinks
  
  def initialize
    @amount, @sale_amount = 0, 0
    @usable_money = Set.new [10, 50, 100, 500, 1000]
    
    #�ŏ��̏��i�R�[�����X�g�b�N
    @drinks = {}
    self.register(:�R�[��, 120)
    5.times{self.add(:�R�[��, 2019, 7, 12)}
    
    #�����_���w���̌�⃊�X�g
    @random_list = [:����, :�R�[��, :�_�C�G�b�g�R�[��]
  end
  
  #���i�̓o�^�i���i��, �l�i�j
  def register(name, price)
    row = {:price => price, :stock => []}
    @drinks.store(name, row)
  end
  
  #���i�̒ǉ�(���i��, �N, ��, ��)
  #�{�����w��ł���悤�ɂ��ׂ����i����܈������₵�����Ȃ��c�j
  def add(name, year, month, date)
    drink = Drink.new(year, month, date)
    @drinks[name][:stock].push(drink)
  end
  
  #�R�C���̓���
  def insert(coin)
    #10�~�ʁA50�~�ʁA100�~�ʁA500�~�ʁA1000�~�D���P�������񓊓��ł���
    #�z��O�̂��̂��������ꂽ�ꍇ�́A�������z�ɉ��Z�����A��������̂܂ܒނ�K�Ƃ��ă��[�U�ɏo�͂���
    if @usable_money.include?(coin)
      @amount += coin
    else
      print("�ޑK#{coin}�~\n")
    end
  end
  
  #�����߂�
  def refund
    #�����߂�������s���ƁA�������z�̑��v��ނ�K�Ƃ��ďo�͂���B
    print("�ޑK#{@amount}�~\n")
    @amount = 0
  end
  
  #�w���\���ǂ����̃`�F�b�N
  def can_purchase(name)
    #�Ԃ�l�F�������z�A�݌ɂ̓_�ŁA�w���ł��邩�ǂ����i�^�U�l�j
    drink = @drinks[name]
    return drink[:price] <= @amount && drink[:stock].size >= 1 && drink[:stock][0].expiration_date >= Date.today
  end
  
  #�w���\�ȏ��i�̃��X�g
  def purchasable_list
    #�Ԃ�l�F�������z�A�݌ɂ̓_�ōw���\�ȃh�����N�̖��O���X�g(�W��)
    #�ܖ������͍��̂Ƃ��떳��
    list = Set.new []
    @drinks.each{|name, drink|
      list.add(name) if drink[:price] <= @amount && drink[:stock].size >= 1
    }
    #�R�[��, �_�C�G�b�g�R�[��, �����̂����w���\�Ȃ��̂�1�ł�����΁D���X�g�Ɂu�����_���v��ǉ�
    #�������i��2��`�F�b�N���Ă���
    list.add(:�����_��) if @random_list.select{|name| self.can_purchase(name)}.size > 0
    return list
  end
  
  #�w��
  #�ʏ�̍w���ƃ����_���w���ő��삪�قȂ�̂����������̂ł܂Ƃ߂�
  #�㏞�Ƃ��ď������򂪉����Ȃ������C�Ƃ肠�������u
  def purchase(name)
    if name == :�����_��
      self.random_purchase
    elsif self.can_purchase(name)
      drink = @drinks[name][:stock].shift
      @sale_amount += @drinks[name][:price]
      @amount -= @drinks[name][:price]
      self.refund
      return drink
    end
  end
  
  #�����_���w��
  #�S�̂�can_purchase��2��s���Ă��邱�ƂɂȂ邯�ǁC�Ƃ肠�������u
  def random_purchase
    list = @random_list.select{|name| self.can_purchase(name)}
    if name = list.sample
      self.purchase(name)
    end
  end
  
end

machine = Vending_machine.new

=begin
machine.insert(100)
machine.insert(1)
machine.insert(50)
p machine.amount
machine.register(:���b�h�u��, 200)
machine.register(:��, 100)
5.times{machine.add(:��, 2019, 8, 1)}
5.times{machine.add(:���b�h�u��, 2019, 8, 1)}
p machine.can_purchase(:��)
p machine.can_purchase(:���b�h�u��)
p machine.purchasable_list
p machine.purchase(:��)
p machine.sale_amount
machine.register(:�����l, 80)
machine.add(:�����l, 2017, 8, 11)
machine.insert(500)
p machine.can_purchase(:�����l)
p machine.drinks[:��][:stock].size
=end

machine.register(:�_�C�G�b�g�R�[��, 120)
5.times{machine.add(:�_�C�G�b�g�R�[��, 2019, 8, 12)}
machine.register(:����, 120)
5.times{machine.add(:����, 2019, 8, 11)}
#�����_����register����Ӗ����Ȃ��̂��኱����������
#machine.register(:�����_��, 120)
machine.insert(500)
p machine.purchase(:�����_��)
