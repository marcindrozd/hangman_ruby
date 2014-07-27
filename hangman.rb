class Hangman
	def initialize
	end

	def drawBoard(item)
		@drawings = [
				"
			   +---+
			   |   |
			       |
			       |
			       |
			       |
			       |
			===========
			", 
			"
			   +---+
			   |   |
			   o   |
			       |
			       |
			       |
			       |
			===========
			", 
			"
			   +---+
			   |   |
			   o   |
			   |   |
			       |
			       |
			       |
			===========
			",
			"
			   +---+
			   |   |
			   o   |
			  /|   |
			       |
			       |
			       |
			===========
			",
			"
			   +---+
			   |   |
			   o   |
			  /|\\  |
			       |
			       |
			       |
			===========
			",
			"
			   +---+
			   |   |
			   o   |
			  /|\\  |
			  /    |
			       |
			       |
			===========
			",
			"
			   +---+
			   |   |
			   o   |
			  /|\\  |
			  / \\  |
			       |
			       |
			===========
			"]
			puts @drawings[item]
		end

	def buildDictionary(filename)
		@dictionary ||= []
		if @dictionary.empty?
			wordlist = File.read(filename).split 
			wordlist.each do |word|
				if word.length > 4 && word.length < 13	
				 	@dictionary << word
				end
			end
		end
		@dictionary
	end

	def getRandomWord
		buildDictionary("5desk.txt")
		wordIndex = Random.rand(0..@dictionary.length - 1)
		@dictionary[wordIndex].downcase
	end

	def displayBoard(missedLetters, correctLetters, secretWord)
		drawBoard(missedLetters.length)
		puts
		
		puts "Missed letters:"
		missedLetters.each_char { |letter| print letter + " " }
		puts
		
		@blanks = []
		secretWord.each_char do |letter|
			if correctLetters.include? letter
				@blanks << letter + " "
			else
				@blanks << "_ "
			end
		end
		
		@blanks.each { |letter| print letter }
		puts
	end

	def runOutOfGuesses?(missedLetters)
		if missedLetters.length == 6
			true
		end
	end

	def marshal_dump
		[@missedLetters, @alreadyGuessed, @correctLetters, @secretWord]
	end

	def marshal_load array
		@missedLetters, @alreadyGuessed, @correctLetters, @secretWord = array
	end

	def saveGame
		File.open("save", "w") do |file|
			Marshal.dump(marshal_dump, file)
		end
	end

	def loadGame
		File.open("save") do |file|
			load = Marshal.load(file)
			marshal_load load
		end
	end

	def getGuess

		while true	
			puts "Guess a letter (or type 'load' or 'save' to load/save game):"
			@guess = gets.chomp.downcase
			
			if @guess == "save"
				saveGame
			elsif @guess == "load"
				if File.exists?("save")
					loadGame
					displayBoard(@missedLetters, @correctLetters, @secretWord)
				else
					puts "There is no save game file"
				end
			elsif @guess.length > 1
				puts "Please enter a single letter"
			elsif @alreadyGuessed.include? @guess
				puts "You have already guessed that letter. Please enter another letter."
			elsif !'abcdefghijklmnopqrstuvwxyz'.include? @guess
				print "Please enter a LETTER."
			else
				@alreadyGuessed = @alreadyGuessed + @guess
				@guess
				break
			end
		end
	end

	def win?(word, correctLetters)
  	letters = word.scan(/./)
  	letters.all? { |letter| correctLetters.include? letter }
	end

	def playAgain?
		puts "Do you want to play again? ('yes' or 'no')"
		@response = gets.chomp.downcase
		if @response == "yes"
			play
		else
			exit
		end
	end

	def play
		@gameIsDone = false
		@missedLetters = ""
		@correctLetters = ""
		@alreadyGuessed = ""
		@secretWord = getRandomWord
		while @gameIsDone == false
			displayBoard(@missedLetters, @correctLetters, @secretWord)
			getGuess
			
			if @secretWord.include? @guess
				@correctLetters = @correctLetters + @guess
				
				if win?(@secretWord, @correctLetters)
					puts "Yes! The secret word is #{@secretWord}! You have won!"
					@gameIsDone = true
					playAgain?
				end
			else
				@missedLetters = @missedLetters + @guess
				puts "The letter is not in the word!"
					
				if runOutOfGuesses?(@missedLetters)
					drawBoard(@missedLetters.length)
					puts "You have run out of guesses\nAfter #{@missedLetters.length} missed guesses and #{@correctLetters.length} correct guesses. The word was '#{@secretWord}'"
					gameIsDone = true
				end
			end
					
			if gameIsDone
				playAgain?
			end
		end
	end
end

new_game = Hangman.new
new_game.play