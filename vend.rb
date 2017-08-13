#!/usr/bin/ruby
#encoding: shift_jis

require 'set'
require "./drink"
#drinkが@drinks[name]の時とDrink.newの2パターンあるので紛らわしい
#賞味期限の登録方法
	#いちいち賞味期限打つのめんどくさい
class Vending_machine
  attr_reader :amount, :sale_amount, :drinks
  
  def initialize
    @amount, @sale_amount = 0, 0
    @usable_money = Set.new [10, 50, 100, 500, 1000]
    
    #最初の商品コーラをストック
    @drinks = {}
    self.register(:コーラ, 120)
    5.times{self.add(:コーラ, 2019, 7, 12)}
    
    #ランダム購入の候補リスト
    @random_list = [:お茶, :コーラ, :ダイエットコーラ]
  end
  
  #商品の登録（商品名, 値段）
  def register(name, price)
    row = {:price => price, :stock => []}
    @drinks.store(name, row)
  end
  
  #商品の追加(商品名, 年, 月, 日)
  #本数も指定できるようにすべきか（あんま引数増やしたくない…）
  def add(name, year, month, date)
    drink = Drink.new(year, month, date)
    @drinks[name][:stock].push(drink)
  end
  
  #コインの投入
  def insert(coin)
    #10円玉、50円玉、100円玉、500円玉、1000円札を１つずつ複数回投入できる
    #想定外のものが投入された場合は、投入金額に加算せず、それをそのまま釣り銭としてユーザに出力する
    if @usable_money.include?(coin)
      @amount += coin
    else
      print("釣銭#{coin}円\n")
    end
  end
  
  #払い戻し
  def refund
    #払い戻し操作を行うと、投入金額の総計を釣り銭として出力する。
    print("釣銭#{@amount}円\n")
    @amount = 0
  end
  
  #購入可能かどうかのチェック
  def can_purchase(name)
    #返り値：投入金額、在庫の点で、購入できるかどうか（真偽値）
    drink = @drinks[name]
    return drink[:price] <= @amount && drink[:stock].size >= 1 && drink[:stock][0].expiration_date >= Date.today
  end
  
  #購入可能な商品のリスト
  def purchasable_list
    #返り値：投入金額、在庫の点で購入可能なドリンクの名前リスト(集合)
    #賞味期限は今のところ無視
    list = Set.new []
    @drinks.each{|name, drink|
      list.add(name) if drink[:price] <= @amount && drink[:stock].size >= 1
    }
    #コーラ, ダイエットコーラ, お茶のうち購入可能なものが1つでもあれば．リストに「ランダム」を追加
    #同じ商品を2回チェックしている
    list.add(:ランダム) if @random_list.select{|name| self.can_purchase(name)}.size > 0
    return list
  end
  
  #購入
  #通常の購入とランダム購入で操作が異なるのが嫌だったのでまとめた
  #代償として条件分岐が汚くなったが，とりあえず放置
  def purchase(name)
    if name == :ランダム
      self.random_purchase
    elsif self.can_purchase(name)
      drink = @drinks[name][:stock].shift
      @sale_amount += @drinks[name][:price]
      @amount -= @drinks[name][:price]
      self.refund
      return drink
    end
  end
  
  #ランダム購入
  #全体でcan_purchaseを2回行っていることになるけど，とりあえず放置
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
machine.register(:レッドブル, 200)
machine.register(:水, 100)
5.times{machine.add(:水, 2019, 8, 1)}
5.times{machine.add(:レッドブル, 2019, 8, 1)}
p machine.can_purchase(:水)
p machine.can_purchase(:レッドブル)
p machine.purchasable_list
p machine.purchase(:水)
p machine.sale_amount
machine.register(:ラムネ, 80)
machine.add(:ラムネ, 2017, 8, 11)
machine.insert(500)
p machine.can_purchase(:ラムネ)
p machine.drinks[:水][:stock].size
=end

machine.register(:ダイエットコーラ, 120)
5.times{machine.add(:ダイエットコーラ, 2019, 8, 12)}
machine.register(:お茶, 120)
5.times{machine.add(:お茶, 2019, 8, 11)}
#ランダムをregisterする意味がないのが若干引っかかる
#machine.register(:ランダム, 120)
machine.insert(500)
p machine.purchase(:ランダム)
