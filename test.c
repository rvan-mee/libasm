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

#define TEST_STRING "Hello World!\n"
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

void test_write()
{
	printf(CYAN "Testing write\n" RESET);
	fflush(stdout);
	// testing with an allocated string
	{
		char *mallocedString = strdup("Hello World\n");
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
		printf("\n");
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
	printf("\n\n");
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
		printf("\n\n");
	}

	// test invalid fd
	{
		read_fd = -1;
		const int libAsm = test_syscall(ft_read(read_fd, buf, 9), "ft_read");
		const int libC = test_syscall(read(read_fd, buf, 9), "read");
		assert(libAsm == libC);
		printf("\n\n");
	}

	// test invalid address
	{
		read_fd = open("Makefile", O_RDONLY);
		const int libAsm = test_syscall(ft_read(read_fd, NULL, 9), "ft_read");
		const int libC = test_syscall(read(read_fd, NULL, 9), "read");
		assert(libAsm == libC);
		close(read_fd);
		printf("\n\n");
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

	printf(GREEN "strcpy test successful" RESET "\n\n");
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

	printf(GREEN "strcmp test successful" RESET "\n\n");
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

	printf(GREEN "strlen test successful" RESET "\n\n");
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

	printf(GREEN "strdup test successful" RESET "\n\n");
}

int main()
{
	test_write();
	test_read();
	test_strcpy();
	test_strcmp();
	test_strlen();
	test_strdup();
	return 0;
}
