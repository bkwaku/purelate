export const getUserDomain = (user) => {
  const data = (user || {}).data || {};
  if (process.env.NODE_ENV === 'development') {
    const port = process.env.REACT_APP_PUBLISHER_PORT || '9222';
    return `localhost:${port}`;
  }
  if (data.domains && data.domains.length > 0) return data.domains[0].domain;
  if (data.slug && process.env.REACT_APP_ROOT_DOMAIN) {
    return `${data.slug}.${process.env.REACT_APP_ROOT_DOMAIN}`;
  }
  return null;
};

export const getProtocol = () => {
  // Always HTTPS in production; HTTP only in dev when HTTPS_DOMAIN=0
  if (process.env.NODE_ENV === 'production') return 'https';
  return Number(process.env.HTTPS_DOMAIN) ? 'https' : 'http';
};

export const getBasePublicUrl = (user) => {
  const protocol = getProtocol();
  const domain = getUserDomain(user) || '';
  return domain ? `${protocol}://${domain}` : '';
};
