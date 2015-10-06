#!/bin/sh
export AUTHFILE="/root/.s3ql/authinfo2"

_getMountDef() {
 grep '#swift' </etc/fstab| sed -e 's/^.//' -e 's/#.*$//'| grep -v "^$"
}

_mount() {
 _isMounted $1 >/dev/null && return 1
 [ -z "$1" -o -z "$1" ] && return 0
 fsck.s3ql --batch --authfile "$AUTHFILE" $([ -n "$3" ] && echo "--backend-options $3") $1 && \
  mount.s3ql --authfile "$AUTHFILE" $([ -n "$3" ] && echo "--backend-options $3") $1 $2
}

_umount() {
 _isMounted $1 >/dev/null || return 1
 [ -z "$1" -o -z "$1" ] && return 0
 local dir=$(mount| grep -w $1| cut -d' ' -f3)
 [ -n "$dir" ] && umount.s3ql $dir
}

_isMounted() {
 [ -z "$1" -o -z "$1" ] && return 0
 if mount| grep -wqs "$1"; then
      echo "Resource \"$1\" is mounted on \"$2\"." && true
 else echo "Resource \"$1\" is not mounted." && false
 fi
}

case "$1" in
  start)
        for i in "$(_getMountDef)"; do
         if ! _mount $i; then _isMounted $i; ret=1; fi
        done
        [ 0$ret -ne 0 ] && exit 1
        for i in "$(_getMountDef)"; do
         _isMounted $i >/dev/null || exit 1
        done
        ;;
  stop)
        for i in "$(_getMountDef)"; do
         ! _umount $i && ! _isMounted $i && exit 1
        done
        ;;
  status)
        for i in "$(_getMountDef)"; do
         _isMounted $i
        done
        ;;
  *)    echo "Usage: $0 {start|stop|status}" >&2; exit 1
esac

exit 0
