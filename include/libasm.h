#ifndef LIBASM_H
# define LIBASM_H

#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>

/* Mandatory */
size_t	ft_strlen(char *s);
size_t	ft_strlen_optimized(char *s);
int32_t	ft_strcmp(const char *s1, const char *s2);
ssize_t	ft_write(int32_t fd, const void *buf, size_t count);
ssize_t	ft_read(int32_t fd, void *buf, size_t count);
char	*ft_strdup(const char *s);
char	*ft_strcpy(char *dest, const char *src);
/*************/

/* Bonus */
typedef struct 	s_list
{
void			*data;
struct s_list	*next;
}				t_list;

int		ft_atoi_base(const char *str, const char *base);
void	ft_list_push_front(t_list **begin_list, void *data);
int		ft_list_size(t_list *begin_list);
void	ft_list_sort(t_list **begin_list, int (*cmp)());
void	ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(), void (*free_fct)(void *));
/*********/

#endif
