library(plumber)
library(dplyr)
library(mongolite)


connection_string = 'mongodb+srv://info448finalapp:info448finalapp@cluster0.x7en1.mongodb.net/finalApp?retryWrites=true&w=majority'
classes_collection = mongo(collection="classes", db="finalApp", url=connection_string)
reviews_collection = mongo(collection="reviews", db="finalApp", url=connection_string)
comments_collection = mongo(collection="comments", db="finalApp", url=connection_string)
isStudent_collection = mongo(collection="isStudent", 
                               db="finalApp", url=connection_string)


#* @apiTitle FinaLApp API
#* @apiDescription API for our 448 Final Project

#* Returns all classes
#* @get /allClasses
function() {
  #as.data.frame(classes_collection$find())
  ratings <- as.data.frame(reviews_collection$find()) %>% group_by(course) %>% summarize_at(vars(numStars), mean)
  colnames(ratings) <- c('classCode', 'avgStars')
  returnVal <- as.data.frame(classes_collection$find())
  returnVal <- left_join(returnVal, ratings, by = "classCode")
  
  returnVal[is.na(returnVal$avgStars),]$avgStars <- 0
  
  returnVal
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

#* Returns all Reviews from a specific user
#* @param course user who wrote reviews
#* @get /allReviewsByCourse
function(course) {
  as.data.frame(reviews_collection$find(paste0('{"course" : "', course,'" }')))
}

#* Returns all Comments from a specific Review
#* @param course course the Review is for 
#* @param author user who wrote review
#* @get /allComentsForReview
function(course, author) {
  as.data.frame(comments_collection$find(paste0('{"reviewCourse":"', course, '", 
                                                "reviewAuthor":"', author, '"}')))
}

#* Uploads review to the db
#* @param course the class that this review is for 
#* @param author user who wrote review
#* @param numStars number of stars given in this review
#* @param description what the user wrote
#* @get /uploadReview
function(course, author, numStars, description) {
  val <- data.frame(course, author, numStars = strtoi(numStars, base=0L), 
                    description, stringsAsFactors=FALSE)
  
  reviews_collection$insert(val)
  
  reviews_collection$update(paste0('{"course":"', course, '", "author":"', author, '"}'), 
                            paste0('{"$set":{"numStars":', numStars, ', "description":"', 
                                   description, '"}}'), upsert = TRUE)
  val
}
#* Uploads review to the db
#* @param course the class that this review is for 
#* @param author user who wrote review
#* @param numStars number of stars given in this review
#* @param description what the user wrote
#* @post /uploadReview
function(course, author, numStars, description) {
  val <- data.frame(course, author, numStars = strtoi(numStars, base=0L), 
                    description, stringsAsFactors=FALSE)
  
  #reviews_collection$insert(val)
  reviews_collection$update(paste0('{"course":"', course, '", "author":"', author, '"}'), 
                            paste0('{"$set":{"numStars":', numStars, ', "description":"', 
                                   description, '"}}'), upsert = TRUE)
  val
}

#* Uploads comment to the db
#* @param reviewCourse the class that the review is for 
#* @param reviewAuthor user who wrote review
#* @param commentAuthor User who wrote comment
#* @param comment The comment the commenter made
#* @get /makeComment
function(reviewCourse,reviewAuthor, commentAuthor, comment) {
  val <- data.frame(reviewCourse, reviewAuthor, commentAuthor, 
                    comment, stringsAsFactors=FALSE)
  
  comments_collection$insert(val)
  val
}

#* Uploads comment to the db
#* @param reviewCourse the class that the review is for 
#* @param reviewAuthor user who wrote review
#* @param commentAuthor User who wrote comment
#* @param comment The comment the commenter made
#* @post /makeComment
function(reviewCourse,reviewAuthor, commentAuthor, comment) {
  val <- data.frame(reviewCourse, reviewAuthor, commentAuthor, 
                    comment, stringsAsFactors=FALSE)
  
  comments_collection$insert(val)
  val
}

#* Registers the student status of a user
#* @param user email for this User
#* @param role role of this user
#* @get /registerUserStatus
function(user, role) {
  
  statusString <- 'false'
  if(role == 'student')
    statusString <- 'true'
  isStudent_collection$update(paste0('{"user":"', user, '"}'), 
                              paste0('{"$set":{"isStudent":', statusString, '}}'), 
                              upsert = TRUE)
  
  return("success")
}

#* Registers the student status of a user
#* @param user email for this User
#* @param role role of this user
#* @post /registerUserStatus
function(user, role) {
  
  statusString <- 'false'
  if(role == 'student')
    statusString <- 'true'
  isStudent_collection$update(paste0('{"user":"', user, '"}'), 
                              paste0('{"$set":{"isStudent":', statusString, '}}'), 
                              upsert = TRUE)
  
  return("success")
}

#* Check whether a user is a student
#* @param user email for this User
#* @get /isStudent
function(user) {
  db_results <- as.data.frame(isStudent_collection$find(paste0('{"user" : "', user,'" }')))
  returnVal <- FALSE
  if(count(db_results) > 0)
    returnVal <- db_results[1,2]
  
  returnVal
}
