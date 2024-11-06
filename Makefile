NAME		:=	libasm.a
TESTER		:=	tester
INCLUDE		:=	include
SRC_DIR		:=	src
SRC_FILES	:=	ft_write.s \
				ft_read.s
SRC_PATH	:=	$(addprefix $(SRC_DIR)/, $(SRC_FILES))

OBJ_DIR		:=	build
OBJ_FILES	:=	$(patsubst %.s, %.o, $(SRC_FILES))
OBJ_PATH	:=	$(addprefix $(OBJ_DIR)/, $(OBJ_FILES))

all: $(NAME)

$(NAME): $(OBJ_PATH)
	rm -f $@
	ar rcs $@ $(OBJ_PATH)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s include/libasm.h
	@mkdir -p $(@D)
	@echo "Compiling: $<"
	@nasm $< -o $@ -f elf64 -g

test: $(NAME) test.c
	@echo "Compiling: $<"
	$(CC) -g test.c -I $(INCLUDE) -o $(TESTER) $(NAME)
	@echo "Running tester"
	@./$(TESTER)

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME)
	rm -f $(TESTER)

re: fclean all

.PHONY: all clean fclean re test
