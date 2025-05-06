{
  'targets': [
    {
      'target_name': 'ada',
      'type': 'shared_library',
      'include_dirs': ['/usr/include/ada'],
      'direct_dependent_settings': {
        'include_dirs': ['/usr/include/ada'],
        'linkflags': ['-lada'],
        'ldflags': ['-lada'],
        'libraries': ['-lada']
      }
    },
  ]
}
