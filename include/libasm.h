#ifndef LIBASM_H
# define LIBASM_H

#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>

// int32_t	ft_strlen(char *s);
// int32_t	ft_strcmp(const char *s1, const char *s2);
int32_t	ft_write(int32_t fd, const void *buf, size_t count);
ssize_t	ft_read(int32_t fd, void *buf, size_t count);
// char	*ft_strdup(const char *s);
// char	*ft_strcpy(char *dest, const char *src);

#endif
