
# journaling
ai_sleep() {
  ffo sleep | ai -p private_sleep
}
alias ais=ai_sleep

ai_people() {
  ai -p private_people "$@"
}
alias aip=ai_people

ai_calys() {
  ffo calys | ai -p private_calys
}
alias aical=ai_calys

ai_food() {
  ffo recipes | ai -p private_recipes
}
alias aif=ai_food

ai_hair() {
  ffo hair | ai -p private_hair
}
alias aih=ai_hair
