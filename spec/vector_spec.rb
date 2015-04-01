require 'eugor/vector'

module Eugor::Vector
  RSpec.describe V2 do
    it "has two numeric properties" do
      v = V2.new(1, 5)
      expect(v.x).to eq(1)
      expect(v.y).to eq(5)
    end

    it "can be tested for equality" do
      a = V2.new(1, 1)
      b = V2.new(1, 1)
      expect(a).to eq(b)
    end

    it "can be added to another" do
      a = V2.new(2, 4)
      b = V2.new(3, 5)
      expect(a + b).to eq(V2.new(5, 9))
    end

    it "can be subtracted from another" do
      a = V2.new(2, 4)
      b = V2.new(3, 5)
      expect(a - b).to eq(V2.new(-1, -1))
    end

    it "can be multiplied by a number" do
      a = V2.new(3, 7)
      k = 5
      expect(a * k).to eq(V2.new(15, 35))
    end

    it "can be divided by a number" do
      a = V2.new(1000, 100)
      d = 10
      expect(a / d).to eq(V2.new(100, 10))
    end

    it "can be modulod by a number" do
      a = V2.new(6, 7)
      d = 5
      expect(a % d).to eq(V2.new(1, 2))
    end

    it "can be multiplied by a vector" do
      a = V2.new(3, 7)
      b = V2.new(5, 2)
      expect(a * b).to eq(V2.new(15, 14))
    end

    it "can be divided by a vector" do
      a = V2.new(1000, 100)
      b = V2.new(10, 5)
      expect(a / b).to eq(V2.new(100, 20))
    end

    it "can be modulod by a vector" do
      a = V2.new(10, 20)
      b = V2.new(9, 10)
      expect(a % b).to eq(V2.new(1, 0))
    end
  end


  RSpec.describe V3 do
    it "has three numeric properties" do
      v = V3.new(1, 5, 29)
      expect(v.x).to eq(1)
      expect(v.y).to eq(5)
      expect(v.z).to eq(29)
    end

    it "can be tested for equality" do
      a = V3.new(1, 1, 1)
      b = V3.new(1, 1, 1)
      expect(a).to eq(b)
    end

    it "can be added to another" do
      a = V3.new(2, 4, 6)
      b = V3.new(3, 5, 7)
      expect(a + b).to eq(V3.new(5, 9, 13))
    end

    it "can be subtracted from another" do
      a = V3.new(2, 4, 6)
      b = V3.new(3, 5, 7)
      expect(a - b).to eq(V3.new(-1, -1, -1))
    end

    it "can be multiplied by a number" do
      a = V3.new(3, 7, 11)
      k = 5
      expect(a * k).to eq(V3.new(15, 35, 55))
    end

    it "can be divided by a number" do
      a = V3.new(1000, 100, 10)
      d = 10
      expect(a / d).to eq(V3.new(100, 10, 1))
    end

    it "can be modulod by a number" do
      a = V3.new(6, 7, 8)
      d = 5
      expect(a % d).to eq(V3.new(1, 2, 3))
    end

    it "can be multiplied by a vector" do
      a = V3.new(3, 7, 11)
      b = V3.new(5, 2, 3)
      expect(a * b).to eq(V3.new(15, 14, 33))
    end

    it "can be divided by a vector" do
      a = V3.new(1000, 100, 10)
      b = V3.new(10, 5, 2)
      expect(a / b).to eq(V3.new(100, 20, 5))
    end

    it "can be modulod by a vector" do
      a = V3.new(10, 20, 30)
      b = V3.new(9, 10, 11)
      expect(a % b).to eq(V3.new(1, 0, 8))
    end

  end
end
