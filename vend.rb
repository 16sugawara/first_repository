#!/usr/bin/ruby
#encoding: shift_jis

require 'set'
require "./drink"
require "./stock"

class Vending_machine
  attr_reader :amount, :sale_amount, :drinks, :change_stock, :sale_stock
  
  def initialize
    @amount, @sale_amount = 0, 0
    @usable_money = Set.new [10, 50, 100, 500, 1000]
    @random_list = Set.new [:お茶, :コーラ, :ダイエットコーラ]
    
    #釣銭管理用にtmpストック，釣銭ストック，売上ストックを作る
    @tmp_stock, @sale_stock = Stock.new(0), Stock.new(0)
    @change_stock = Stock[10,10, 50,10, 100,10, 500,10, 1000,10]
    
    #最初の商品コーラを格納
    @drinks = {}
    self.register(:コーラ, 120)
    5.times{self.add(:コーラ, 2019, 7, 12)}
  end
  
  #商品の登録（商品名, 値段）
  def register(name, price)
    @drinks.store(name, {:stock => [], :price => price})
  end
  
  #商品の追加(商品名, 年, 月, 日)
  def add(name, year, month, date)
    drink = Drink.new(year, month, date)
    @drinks[name][:stock].push(drink)
  end
  
  #コインの投入
  def insert(coin)
    if @usable_money.include?(coin)
      @tmp_stock[coin] += 1
      @amount += coin
    else
      print("釣銭#{coin}円\n")
    end
  end
  
  #払い戻し
  def refund(change = @amount)
    print("釣銭#{change}円\n")
    @amount = 0
    @tmp_stock.clear
  end
  
  #購入可能かどうかのチェック
  def can_purchase(name)
    if name == :ランダム
      return @random_list.any?{|name| @drinks[name][:price] <= @amount && @drinks[name][:stock].size >= 1 && @drinks[name][:stock][0].expiration_date >= Date.today}
    else
      return @drinks[name][:price] <= @amount && @drinks[name][:stock].size >= 1 && @drinks[name][:stock][0].expiration_date >= Date.today
    end
  end
  
  #購入可能な商品のリスト
  def purchasable_list
    #返り値：投入金額，在庫，賞味期限の点で購入可能なドリンクの名前リスト(集合)
    list = Set.new []
    @drinks.each_key{|name|
      list.add(name) if self.can_purchase(name)
    }
    list.add(:ランダム) if list.intersect?(@random_list)
    return list
  end
  
  #購入
  def purchase(name)
    change = @amount - @drinks[name][:price]
    if self.can_purchase(name) && self.can_pay(change)
      name = self.random_select if name == :ランダム
      @sale_amount += @drinks[name][:price]
      @tmp_stock.combine(@change_stock, @sale_stock)
      @change_stock.reduce(change)
      self.refund(change)
      return @drinks[name][:stock].shift
    end
  end
  
  #釣銭が払えるかどうか
  def can_pay(change)
    ct_stock = @change_stock.merge(@tmp_stock){|key, v0, v1| v0 + v1}
    if ct_stock.reduce(change) == 0
      return true
    else
      return false
    end
  end
  
  #ランダムセレクト
  def random_select
    list = @random_list.select{|name| self.can_purchase(name)}
    if list.size > 0
      return list.sample
    end
  end
  
end