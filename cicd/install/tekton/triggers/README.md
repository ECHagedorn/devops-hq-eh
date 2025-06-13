# To use triggers you will need to install the CRDs that will enable eventlisteners, execute the following:
    $ kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Make sure to install interceptors for the eventListener
    $ kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml

# The current CRD at 0.32.0 is supposed to control the svc of the eventListener, we would typically be able to define serviceType on the eventListener.yaml just bove triggers. However this is not currently merged, so a workaround to get a webhook setup for the eventListener is to expose the existing svc and create and externally accessible svc.

    $ kubectl expose svc event-listener -n default --type=NodePort --name=event-listener-external -n tekton-pipelines

