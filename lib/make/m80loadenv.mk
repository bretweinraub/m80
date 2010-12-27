ifdef M80_BDF
  ifdef M80_REPOSITORY

    bdfExists=$(wildcard $(M80_REPOSITORY)/bdfs/$(M80_BDF).mk)

    ifneq ($(bdfExists),)
      include $(M80_REPOSITORY)/bdfs/$(M80_BDF).mk

      ifneq ($(ENV),)
        include $(M80_REPOSITORY)/environments/$(ENV).mk
      endif

      ifneq ($(PROJECT),)
        include $(M80_REPOSITORY)/projects/$(PROJECT).mk
      endif
    endif
  endif
endif
