NAME		:=	libasm.a
TESTER		:=	tester
INCLUDE		:=	include
SRC_DIR		:=	src
SRC_FILES	:=	ft_write.s	\
				ft_read.s	\
				ft_strcpy.s	\
				ft_strcmp.s	\
				ft_strlen.s	\
				ft_strdup.s	\
				ft_list_size.s \
				ft_list_push_front.s

SRC_PATH	:=	$(addprefix $(SRC_DIR)/, $(SRC_FILES))

OBJ_DIR		:=	build
OBJ_FILES	:=	$(patsubst %.s, %.o, $(SRC_FILES))
OBJ_PATH	:=	$(addprefix $(OBJ_DIR)/, $(OBJ_FILES))

all: $(NAME)

$(NAME): $(OBJ_PATH)
	@rm -f $@
	@ar rcs $@ $(OBJ_PATH)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s include/libasm.h
	@mkdir -p $(@D)
	@echo "Compiling: $<"
	@nasm $< -o $@ -f elf64 -g

test: $(NAME) test.c
	@echo "Compiling: test.c"
	@$(CC) -g -Wall -Werror -Wextra -Wno-nonnull test.c -I $(INCLUDE) -o $(TESTER) $(NAME)
	@echo "Running tester"
	@./$(TESTER)

clean:
	@echo "Cleaning object directory"
	@rm -rf $(OBJ_DIR)

fclean: clean
	@echo "Cleaning $(NAME)"
	@rm -f $(NAME)
	@echo "Cleaning $(TESTER)"
	@rm -f $(TESTER)

re: fclean all

.PHONY: all clean fclean re test
