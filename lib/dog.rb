class Dog
	attr_accessor :name, :breed, :id

	# ATTRIBUTES = { 
 #      id: "Integer",
 #      name: "Text",
 #      breed: "Text",
 #    }

	def initialize (name:, breed:, id: nil)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		self.drop_table

		sql = <<-SQL
			CREATE TABLE dogs(
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT);
		SQL

		DB[:conn].execute(sql)

	end

	def self.drop_table
		DB[:conn].execute('DROP TABLE IF EXISTS dogs')
	end

	def self.create(name:, breed:)
		dog = self.new(name: name, breed:breed)
		dog.save
		dog
	end

	def insert
		sql = <<-SQL
			INSERT INTO dogs (name, breed)
			VALUES (?,?)
		SQL

		values = [self.name, self.breed]
		DB[:conn].execute(sql, *values)[0]
		self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
	end

	def update
		sql = <<-SQL
     		UPDATE dogs SET name=?, breed=?
     		WHERE id = #{self.id}
    	SQL

    	values = [self.name, self.breed]
    	DB[:conn].execute(sql, *values)
	end

	def persisted?
    	!!id
  	end

 	def save
 	  	if persisted?
       		self.update
      	else
      		self.insert
    	end
    	self
  	end

  	def self.find_by_id(id)

  		sql = <<-SQL
  			SELECT * FROM dogs 
  			WHERE id = '#{id}' 
  			LIMIT 1
  		SQL
  		row = DB[:conn].execute(sql).flatten
  		self.new_from_db(row)
  	end

  	def self.find_by_name(name)
  		sql = <<-SQL
  			SELECT * FROM dogs 
  			WHERE name = '#{name}' 
  			LIMIT 1
  		SQL
  		row = DB[:conn].execute(sql).flatten
  		self.new_from_db(row)
  	end

  	def self.new_from_db(row)
  		dog = self.new(name: row[1], breed:row[2])
  		dog.id = row[0]
  		dog
  	end

  	def self.find_or_create_by(name: name, breed: breed)
  		dog = ''
  		sql = <<-SQL
  			SELECT * FROM dogs 
  			WHERE name = '#{name}' AND breed = '#{breed}'
  			ORDER BY id
  			LIMIT 1
  		SQL

  		row = DB[:conn].execute(sql).first

  		if row == nil
  			dog = self.create(name: name, breed: breed)
  		else
  			dog = self.new_from_db(row)
  			# binding.pry 
  		end
  		dog
  	end


end







