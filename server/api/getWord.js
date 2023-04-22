const getWord = () => {
    const words = [
      'Apple', 'Arrow', 'Ant', 'Airplane', 'Anchor', 'Angel', 'Axe', 'Baby', 'Balloon', 'Banana', 'Baseball', 'Basketball',
      'Beach', 'Bear', 'Bee', 'Bicycle', 'Bird', 'Boat', 'Book', 'Bottle', 'Bowtie', 'Box', 'Bread', 'Bridge', 'Broccoli',
      'Bus', 'Butterfly', 'Cake', 'Camera', 'Candle', 'Car', 'Cat', 'Chair', 'Cheese', 'Cherries', 'Chicken', 'Chimney',
      'Circle', 'Clock', 'Cloud', 'Coffee', 'Compass', 'Computer', 'Cookie', 'Cow', 'Crab', 'Crayon', 'Crocodile', 'Crown',
      'Cup', 'Daffodil', 'Deer', 'Diamond', 'Dice', 'Dolphin', 'Donut', 'Door', 'Dragon', 'Dragonfly', 'Drum', 'Duck',
      'Eagle', 'Earrings', 'Egg', 'Elephant', 'Envelope', 'Eye', 'Eyeglasses', 'Falcon', 'Feather', 'Fence', 'Finger',
      'Fish', 'Flag', 'Flamingo', 'Flashlight', 'Flower', 'Flying saucer', 'Football', 'Fork', 'Fountain', 'Fox',
      'Frog', 'Frying pan', 'Giraffe', 'Girl', 'Glass', 'Globe', 'Glove', 'Goat', 'Grapes', 'Guitar', 'Hamburger',
      'Hammer', 'Hand', 'Hat', 'Helicopter', 'Helmet', 'Hippo', 'Horse', 'Hot air balloon', 'Hot dog', 'House', 'Ice cream',
      'Igloo', 'Insect', 'Jacket', 'Jellyfish', 'Jewelry', 'Kangaroo', 'Key', 'Keyboard', 'Kite', 'Knife', 'Ladybug',
      'Lamp', 'Laptop', 'Leaf', 'Lemon', 'Lighthouse', 'Lightning', 'Lion', 'Lipstick', 'Lizard', 'Lock', 'Lollipop',
      'Luggage', 'Map', 'Marker', 'Mars', 'Mermaid', 'Microphone', 'Mirror', 'Monkey', 'Moon', 'Mosquito', 'Motorcycle',
      'Mountain', 'Mouse', 'Mushroom', 'Nail', 'Nose', 'Owl', 'Palm tree', 'Pancakes', 'Panda', 'Pants', 'Paper clip',
      'Parachute', 'Parrot', 'Peach', 'Pear', 'Pencil', 'Penguin', 'Piano', 'Pickup truck', 'Pig', 'Pineapple', 'Pizza',
      'Planet', 'Purse', 'Rabbit', 'Rain', 'Rainbow', 'Raincoat', 'Rake', 'Remote control', 'Rhino', 'River', 'Robot',
      'Rocket', 'Roller skates', 'Rose', 'Sandwich', 'Satellite', 'Scissors', 'Scorpion', 'Sea turtle', 'Shark', 'Sheep',
      'Shirt', 'Shoe', 'Shorts', 'Shower', 'Snail', 'Snake', 'Sneakers', 'Snowflake'];
    
  
    return words[Math.floor(Math.random() * words.length)];
  };
  
  module.exports = getWord;