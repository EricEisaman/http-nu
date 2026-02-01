[
  { quote: "The best way to predict the future is to create it.", who: "Peter Drucker" }
  { quote: "Simplicity is the ultimate sophistication.", who: "Leonardo da Vinci" }
  { quote: "Code is like humor. When you have to explain it, it’s bad.", who: "Cory House" }
  { quote: "First, solve the problem. Then, write the code.", who: "John Johnson" }
  { quote: "Optimism is an occupational hazard of programming: feedback is the treatment.", who: "Kent Beck" }
] | each {|q| $q | .append quotes --meta $q }
