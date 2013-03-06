# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts "Creating User seed data . . ."
User.delete_all
User.create(:name => 'vader', :password => 'anakin')
puts "Done"

# Product Data => Query against Milestone DB :
# select sappartnumber, sapshortdescription, rpwo, imagepath, createddate, tempsoldtopartynumber from octmaterialmaster
# where completed = 1 and configclass = 0 order by sappartnumber;

# puts "Creating Product seed data . . ."
# Product.delete_all
# open(Rails.root.join('db/data/Products.txt')) do |products|
  # products.read.each_line do |product|
    # mm_number, description, rpwo, image_path, material_created_on, customer = product.chomp.split("|")
    # Product.create!(mm_number: mm_number, description: description, rpwo: rpwo, image_path: image_path, material_created_on: material_created_on, customer: customer)
  # end
# end
# puts "Done"

# ListPriceSet Data => Query against Milestone DB :
# select uniqueid, name, active, startdate, enddate, modificationdate from octlistpriceset order by uniqueid;

puts "Creating ListPriceSet seed data . . ."
ListPriceSet.delete_all
open(Rails.root.join('db/data/ListPriceSets.txt')) do |list_price_sets|
  list_price_sets.read.each_line do |list_price_set|
    unique_id, name, active, start_date, end_date, modification_date = list_price_set.chomp.split("|")
    ListPriceSet.create!(unique_id: unique_id, name: name, active: active, start_date: start_date, end_date: end_date, modification_date: modification_date)
  end
end
puts "Done"

# Sales Org Data => Query against Milestone DB :
# select code, description, salesorg, currency from octsalesorg order by salesorg;

puts "Creating Sales Org seed data . . ."
SalesOrg.delete_all
open(Rails.root.join('db/data/SalesOrgs.txt')) do |sales_orgs|
  sales_orgs.read.each_line do |sales_org|
    code, description, salesorg, currency  = sales_org.chomp.split("|")
    SalesOrg.create!(code: code, description: description, sales_org:salesorg, currency:currency)
  end
end
puts "Done"

# ProductPricingAdjustment Data => Query against Milestone DB :
# select sappartnumber, salesorg, listprice, listpriceset, active from octproductadjustment where sappartnumber in (
# select sappartnumber from octmaterialmaster where completed = 1 and configclass = 0
# ) order by sappartnumber, salesorg, listpriceset;

puts "Creating ProductPricingAdjustment seed data . . ."
ProductPrice.delete_all
open(Rails.root.join('db/data/ProductPricingAdjustments.txt')) do |adjustments|
  adjustments.read.each_line do |adjustment|
    product_id, sales_org, list_price, list_price_set, active  = adjustment.chomp.split("|")
    found_product = Product.find_by_mm_number(product_id)
    product_id = found_product.id unless found_product.nil?
    found_sales_org = SalesOrg.find_by_code(sales_org)
    sales_org_id = found_sales_org.id unless found_sales_org.nil?
    ProductPrice.create!(product_id: product_id, sales_org_id: sales_org_id, list_price: list_price, list_price_set: list_price_set, active: active) unless (product_id.nil? || sales_org_id.nil?)
  end
end
puts "Done"

# ProductDescription Data => Query against Milestone DB :
# select uniqueid, sappartnumber, locale, shortdescription, mediumdescription, longdescription from mmdescriptions@LANGUAGE
# where sappartnumber in (select sappartnumber from octmaterialmaster where completed = 1 and configclass = 0)
# and locale = 'en_US'
# order by sappartnumber, locale;

# puts "Creating ProductDescription seed data . . ."
# ProductDescription.delete_all
# open(Rails.root.join('db/data/ProductDescriptions.txt')) do |descriptions|
  # descriptions.read.each_line do |description|
    # unique_id, mm_number, locale, short_description, medium_description, long_description  = description.chomp.split("<ryan_delim>")
    # puts "#{unique_id} : MM= #{mm_number}"
    # ProductDescription.create!(unique_id: unique_id, mm_number: mm_number, locale: locale, short_description: short_description, medium_description: medium_description, long_description: long_description) unless unique_id.nil?
  # end
# end
# puts "Done"
