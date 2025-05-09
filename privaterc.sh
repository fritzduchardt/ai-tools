
# journaling
ai_sleep() {
  cfo sleep | ai -p private_sleep
}
alias ais=ai_sleep

ai_people() {
  ai -p private_people "$@"
}
alias aip=ai_people

ai_calys() {
  cfo calys | ai -p private_calys
}
alias aical=ai_calys

ai_food() {
  cfo recipes | ai -p private_recipes
}
alias aif=ai_food

ai_hair() {
  cfo hair | ai -p private_hair
}
alias aih=ai_hair
