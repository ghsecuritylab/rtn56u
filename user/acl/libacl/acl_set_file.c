/*
  File: acl_set_file.c

  Copyright (C) 1999, 2000
  Andreas Gruenbacher, <a.gruenbacher@computer.org>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "../../attr/include/xattr.h"
#include "libacl.h"
#include "__acl_to_xattr.h"

#include "byteorder.h"
#include "acl_ea.h"


/* 23.4.22 */
int
acl_set_file(const char *path_p, acl_type_t type, acl_t acl)
{
	acl_obj *acl_obj_p = ext2int(acl, acl);
	char *ext_acl_p;
	const char *name;
	size_t size;
	int error;

	if (!acl_obj_p)
		return -1;
	switch (type) {
		case ACL_TYPE_ACCESS:
			name = ACL_EA_ACCESS;
			break;
		case ACL_TYPE_DEFAULT:
			name = ACL_EA_DEFAULT;
			break;
		default:
			errno = EINVAL;
			return -1;
	}

	if (type == ACL_TYPE_DEFAULT) {
		struct stat st;

		if (stat(path_p, &st) != 0)
			return -1;

		/* Only directories may have default ACLs. */
		if (!S_ISDIR(st.st_mode)) {
			errno = EACCES;
			return -1;
		}
	}

	ext_acl_p = __acl_to_xattr(acl_obj_p, &size);
	if (!ext_acl_p)
		return -1;
	error = setxattr(path_p, name, (char *)ext_acl_p, size, 0);
	free(ext_acl_p);
	return error;
}

