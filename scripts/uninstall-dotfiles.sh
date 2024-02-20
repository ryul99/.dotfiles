#! /bin/bash

# unlink symbolic links to .dotfiles at HOME

printf 'Going to remove below files... Continue? (Answer in 1 or 2)\n\n'

FILES=$(find $HOME -lname *dotfiles* -maxdepth 1)

printf '%s\n' "${FILES[@]}"; printf '\n'
select yn in "Yes" "No"; do
    case $yn in
        Yes ) rm -rf $FILES; exit 0;;
        No ) exit 0;;
        * ) echo 'select in 1 or 2';
    esac
done

