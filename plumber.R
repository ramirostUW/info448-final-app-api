library(plumber)
library(mongolite)


connection_string = 'mongodb+srv://info448finalapp:info448finalapp@cluster0.x7en1.mongodb.net/finalApp?retryWrites=true&w=majority'
classes_collection = mongo(collection="classes", db="finalApp", url=connection_string)
reviews_collection = mongo(collection="reviews", db="finalApp", url=connection_string)


#* @apiTitle FinaLApp API
#* @apiDescription API for our 448 Final Project

#* Returns all classes
#* @get /allClasses
function() {
  as.data.frame(classes_collection$find())
}


#* Returns all reviews
#* @get /allReviews
function() {
  as.data.frame(reviews_collection$find())
}

#* Returns all Reviews from a specific user
#* @param author user who wrote reviews
#* @get /allReviewsByUser
function(author) {
  as.data.frame(reviews_collection$find(paste0('{"author" : "', author,'" }')))
}

#* Returns countries that satisfy condition
#* @param course the class that this review is for 
#* @param author user who wrote review
#* @param numStars number of stars given in this review
#* @param description what the user wrote
#* @get /uploadReview
function(course, author, numStars, description) {
  val <- data.frame(course, author, numStars, description, stringsAsFactors=FALSE)
  
  reviews_collection$insert(val)
  
  val
}
#* Returns countries that satisfy condition
#* @param course the class that this review is for 
#* @param author user who wrote review
#* @param numStars number of stars given in this review
#* @param description what the user wrote
#* @post /uploadReview
function(course, author, numStars, description) {
  val <- data.frame(course, author, numStars, description, stringsAsFactors=FALSE)
  
  reviews_collection$insert(val)
  
  val
}