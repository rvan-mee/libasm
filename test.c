// ooooo        ooooo oooooooooo.        .o.        .oooooo..o ooo        ooooo 
// `888'        `888' `888'   `Y8b      .888.      d8P'    `Y8 `88.       .888' 
//  888          888   888     888     .8"888.     Y88bo.       888b     d'888  
//  888          888   888oooo888'    .8' `888.     `"Y8888o.   8 Y88. .P  888  
//  888          888   888    `88b   .88ooo8888.        `"Y88b  8  `888'   888  
//  888       o  888   888    .88P  .8'     `888.  oo     .d8P  8    Y     888  
// o888ooooood8 o888o o888bood8P'  o88o     o8888o 8""88888P'  o8o        o888o 

#include <libasm.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <assert.h>
#include <fcntl.h>
#include <time.h>
#include <stdarg.h>

#define TEST_STRING "Hello World!\n"
#define REALLY_LONG_STRING_SIZE (100 * 1024 * 1024)
#define RESET       "\x1b[0m"
#define BLACK       "\x1b[30m"
#define RED         "\x1b[31m"
#define GREEN       "\x1b[32m"
#define YELLOW      "\x1b[33m"
#define BLUE        "\x1b[34m"
#define MAGENTA     "\x1b[35m"
#define CYAN        "\x1b[36m"
#define WHITE       "\x1b[37m"


int test_syscall(int ret, char *str)
{
	if (ret < 0)
	{
		printf(RED "syscall failed" RESET " for: %s, reason: %s\n", str, strerror(errno));
	}
	return ret;
}

t_list*	remove_node_and_move_next(t_list* node)
{
	t_list* next_node = node->next;

	free(node->data);
	free(node);
	return (next_node);
}

void clear_list(t_list* list)
{
	while (list)
		list = remove_node_and_move_next(list);
}

t_list*	create_node(int num)
{
	t_list*	new_node = malloc(sizeof(t_list));
	int*	alloced_num = malloc(sizeof(int));

	*alloced_num = num;
	new_node->data = alloced_num;
	new_node->next = NULL;
	return (new_node);
}

t_list*	create_initialized_list(int arg_count, ...)
{
	va_list	args;
	t_list*	head = NULL;
	t_list* new_node = NULL;

	va_start(args, arg_count);
	while (arg_count--)
	{
		if (!head)
		{
			head = create_node(va_arg(args, int32_t));
			new_node = head;
		}
		else
		{
			new_node->next = create_node(va_arg(args, int32_t));
			new_node = new_node->next;
		}
	}
	va_end(args);
	return (head);
}

t_list*	create_list(size_t size)
{
	t_list* listHead = NULL;
	t_list* current = NULL;
	size_t	i = 0;

	while (i != size)
	{
		if (!listHead)
		{
			listHead = malloc(sizeof(t_list));
			current = listHead;
		}
		else
		{
			current->next = malloc(sizeof(t_list));
			current = current->next;
		}
		current->data = NULL;
		current->next = NULL;
		i++;
	}
	return (listHead);
}

void test_write()
{
	printf(CYAN "Testing write\n" RESET);
	fflush(stdout);
	// testing with an allocated string
	{
		char *mallocedString = strdup(TEST_STRING);
		const int libC = test_syscall(write(STDOUT_FILENO, mallocedString, strlen(mallocedString)), "write");
		const int libAsm = test_syscall(ft_write(STDOUT_FILENO, mallocedString, strlen(mallocedString)), "ft_write");
		free(mallocedString);
		assert(libC == libAsm);
		printf("\n");
	}

	// testing with a string literal
	{
		const int libC = test_syscall(write(STDOUT_FILENO, TEST_STRING, sizeof(TEST_STRING)), "write");
		const int libAsm = test_syscall(ft_write(STDOUT_FILENO, TEST_STRING, sizeof(TEST_STRING)), "ft_write");
		assert(libC == libAsm);
		printf("\n");
	}

	// testing with an empty string literal
	{
		const int libC = test_syscall(write(STDOUT_FILENO, "", sizeof("")), "write");
		const int libAsm = test_syscall(ft_write(STDOUT_FILENO, "", sizeof("")), "ft_write");
		assert(libC == libAsm);
	}

	// testing with a wrong fd
	{
		const int libAsm = test_syscall(ft_write(-1, TEST_STRING, sizeof(TEST_STRING)), "ft_write");
		const int libC = test_syscall(write(-1, TEST_STRING, sizeof(TEST_STRING)), "write");
		assert(libC == libAsm);
		printf("\n");
	}

	// testing with an invalid pointer
	{
		const char *buf = (char *)0xFFFFFFFF;
		const int libAsm = test_syscall(ft_write(STDOUT_FILENO, buf, 1), "ft_write");
		const int libC = test_syscall(write(STDOUT_FILENO, buf, 1), "write");
		assert(libC == libAsm);
	}
	printf("\n");
}

void test_read()
{
	int read_fd;
	char buf[10];
	memset(buf, 0, 10);

	// Read check
	{
		read_fd = open("Makefile", O_RDONLY);
		const int libAsm = test_syscall(ft_read(read_fd, buf, 9), "ft_read");
		printf("--%s--\n", buf);
		lseek(read_fd, 0, SEEK_SET);
		memset(buf, 0, 10);
		const int libC = test_syscall(read(read_fd, buf, 9), "read");
		printf("--%s--\n", buf);
		assert(libAsm == libC);
		lseek(read_fd, 0, SEEK_SET);
		memset(buf, 0, 10);
		close(read_fd);
		printf("\n");
	}

	// test invalid fd
	{
		read_fd = -1;
		const int libAsm = test_syscall(ft_read(read_fd, buf, 9), "ft_read");
		const int libC = test_syscall(read(read_fd, buf, 9), "read");
		assert(libAsm == libC);
		printf("\n");
	}

	// test invalid address
	{
		read_fd = open("Makefile", O_RDONLY);
		const int libAsm = test_syscall(ft_read(read_fd, NULL, 9), "ft_read");
		const int libC = test_syscall(read(read_fd, NULL, 9), "read");
		assert(libAsm == libC);
		close(read_fd);
		printf("\n");
	}
}

void test_strcpy()
{
	// test regular string
	{
		const char *src = TEST_STRING;
		char dest[sizeof(TEST_STRING)];
		char *ret = NULL;

		ret = ft_strcpy(dest, src);
		assert(ret == dest);
		assert(strcmp(dest, src) == 0);
	}

	// test empty string
	{
		const char *src = "";
		char dest[10];
		char *ret = NULL;

		ret = ft_strcpy(dest, src);
		assert(ret == dest);
		assert(strcmp(dest, src) == 0);
	}

	printf(GREEN "strcpy test successful" RESET "\n");
}

void test_strcmp()
{
	// test strings equal
	{
		const char *s1 = TEST_STRING;
		const char *s2 = TEST_STRING;

		assert(ft_strcmp(s1, s2) == 0 && strcmp(s1, s2) == 0);
	}

	// test strings not equal negative
	{
		const char *s1 = TEST_STRING;
		const char *s2 = "hello woold\n";

		assert(ft_strcmp(s1, s2) < 0 && strcmp(s1, s2) < 0);
	}

	// test strings not equal positive
	{
		const char *s1 = "Hello world?\n";
		const char *s2 = TEST_STRING;

		assert(ft_strcmp(s1, s2) > 0 && strcmp(s1, s2) > 0);
	}

	printf(GREEN "strcmp test successful" RESET "\n");
}

void test_strlen()
{
	// test regular string
	{
		assert(ft_strlen(TEST_STRING) == strlen(TEST_STRING));
	}

	// test empty string
	{
		assert(ft_strlen("") == strlen(""));
	}

	// test regular string
	{
		assert(ft_strlen_optimized(TEST_STRING) == strlen(TEST_STRING));
	}

	// test empty string
	{
		assert(ft_strlen_optimized("") == strlen(""));
	}

	// test speed difference
	{
		clock_t start_time, end_time;

		char *really_long_string = malloc(REALLY_LONG_STRING_SIZE + 1);
		memset(really_long_string, 'R', REALLY_LONG_STRING_SIZE);
		really_long_string[REALLY_LONG_STRING_SIZE] = '\0';

		start_time = clock();
		ssize_t sizeLibC = strlen(really_long_string);
		end_time = clock();
		double time_taken_libC = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

		start_time = clock();
		ssize_t sizeLibAsm = ft_strlen(really_long_string);
		end_time = clock();
		double time_taken_libAsm = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

		start_time = clock();
		ssize_t sizeLibAsm_optimized = ft_strlen_optimized(really_long_string);
		end_time = clock();
		double time_taken_libAsm_optimized = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

		free(really_long_string);

		assert(sizeLibAsm == sizeLibC && sizeLibAsm == sizeLibAsm_optimized);
		printf("Benchmarking strlen:\n"
				"LibC: %f\n"
				"LibAsm (unoptimized): %f\n"
				"LibAsm (optimized): %f\n",
				time_taken_libC, time_taken_libAsm, time_taken_libAsm_optimized);
	}

	printf(GREEN "strlen test successful" RESET "\n");
}

void test_strdup()
{
	// test regular string
	{
		char *strLibAsm = ft_strdup(TEST_STRING);
		char *strLibC = strdup(TEST_STRING);

		assert(strcmp(strLibAsm, strLibC) == 0);
		free(strLibAsm);
		free(strLibC);
	}

	// test empty string
	{
		char *strLibAsm = ft_strdup("");
		char *strLibC = strdup("");

		assert(strcmp(strLibAsm, strLibC) == 0);
		free(strLibAsm);
		free(strLibC);
	}

	printf(GREEN "strdup test successful" RESET "\n");
}

void test_list_size()
{
	t_list* list_20 = create_list(20);
	t_list* list_10 = create_list(10);
	t_list* list_0 = create_list(0);

	assert(ft_list_size(list_20) == 20);
	assert(ft_list_size(list_10) == 10);
	assert(ft_list_size(list_0) == 0);

	clear_list(list_20);
	clear_list(list_10);
	clear_list(list_0);

	printf(GREEN "list_size test successful" RESET "\n");
}

void test_list_push_front()
{
	t_list* list_10 = create_list(10);
	char *data_string = strdup(TEST_STRING);

	ft_list_push_front(&list_10, data_string);
	assert(ft_list_size(list_10) == 11);
	assert(strcmp(list_10->data, TEST_STRING) == 0);

	ft_list_push_front(NULL, NULL);

	clear_list(list_10);

	printf(GREEN "list_push_front test successful" RESET "\n");
}

int	list_sort_compare_func(int *a, int *b)
{
  return (*a < *b) - (*b < *a);
}

int	list_remove_if_compare_func(int* data, int* data_ref)
{
	int incoming_data = *data;
	int comparing_data = *data_ref;

	return (incoming_data != comparing_data); 
}

void free_func(void* data)
{
	free(data);
}

void sorted_check(t_list* list)
{
	while (list && list->next)
	{
		assert(list_sort_compare_func(list->data, list->next->data) <= 0);
		list = remove_node_and_move_next(list);
	}
	if (list)
		list = remove_node_and_move_next(list);
}

void test_list_sort()
{
	t_list* list = create_initialized_list(11, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, -1);
	t_list* list2 = create_initialized_list(11, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8 ,9);

	ft_list_sort(&list, list_sort_compare_func);
	sorted_check(list);
	
	ft_list_sort(&list2, list_sort_compare_func);
	sorted_check(list2);

	printf(GREEN "list_sort test successful" RESET "\n");
}

void	test_list_remove_if()
{
	t_list*	list = create_initialized_list(6, 0, 1, 0, 1, 0, 1);
	void* data_ref = malloc(sizeof(int));

	*(int*)data_ref = 1;
	ft_list_remove_if(&list, data_ref, &list_remove_if_compare_func, &free_func);

	t_list* node = list;

	while (node)
	{
		assert((*(int*)node->data) != *(int *)data_ref);
		node = node->next;
	}

	free(data_ref);
	clear_list(list);
	printf(GREEN "list_remove_if test successful" RESET "\n");
}

int main()
{
	test_write();
	test_read();
	test_strcpy();
	test_strcmp();
	test_strlen();
	test_strdup();
	printf("\n" BLUE "Testing bonus functions:\n" RESET);
	test_list_size();
	test_list_push_front();
	test_list_sort();
	test_list_remove_if();
	return 0;
}
